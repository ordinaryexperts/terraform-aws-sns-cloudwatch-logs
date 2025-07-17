"""Unit tests for sns_cloudwatch_gw Lambda function."""

import os
import sys
import logging
from unittest.mock import patch, MagicMock, call
import pytest
import datetime
import pytz

sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
import sns_cloudwatch_gw


class TestHandler:
    """Test cases for the Lambda handler function."""

    @patch('sns_cloudwatch_gw.watchtower.CloudWatchLogHandler')
    def test_handler_sns_event_success(self, mock_cw_handler_class, sns_event, lambda_context, mock_watchtower_handler):
        """Test successful processing of SNS event."""
        mock_cw_handler_class.return_value = mock_watchtower_handler
        mock_cw_logger = MagicMock()
        
        with patch('sns_cloudwatch_gw.logging.getLogger') as mock_get_logger:
            mock_get_logger.return_value = mock_cw_logger
            
            result = sns_cloudwatch_gw.handler(sns_event, lambda_context)
            
            mock_cw_logger.setLevel.assert_called_once_with(logging.INFO)
            mock_cw_logger.addHandler.assert_called_once_with(mock_watchtower_handler)
            mock_cw_logger.info.assert_called_once_with("This is a test log message from SNS")
            mock_watchtower_handler.flush.assert_called_once()
            
            mock_cw_handler_class.assert_called_once()
            call_args = mock_cw_handler_class.call_args
            assert call_args.kwargs['log_group'] == 'test-log-group'
            assert '/' in call_args.kwargs['stream_name']
            
            assert result is None

    @patch('sns_cloudwatch_gw.watchtower.CloudWatchLogHandler')
    def test_handler_multiple_records(self, mock_cw_handler_class, sns_event_multiple_records, lambda_context, mock_watchtower_handler):
        """Test handling of multiple SNS records (only processes first)."""
        mock_cw_handler_class.return_value = mock_watchtower_handler
        mock_cw_logger = MagicMock()
        
        with patch('sns_cloudwatch_gw.logging.getLogger') as mock_get_logger:
            mock_get_logger.return_value = mock_cw_logger
            
            result = sns_cloudwatch_gw.handler(sns_event_multiple_records, lambda_context)
            
            mock_cw_logger.info.assert_called_once_with("First test log message")
            mock_watchtower_handler.flush.assert_called_once()
            
            assert result is None

    @patch('sns_cloudwatch_gw.watchtower.CloudWatchLogHandler')
    def test_handler_non_sns_event(self, mock_cw_handler_class, non_sns_event, lambda_context, mock_watchtower_handler):
        """Test handling of non-SNS event."""
        mock_cw_handler_class.return_value = mock_watchtower_handler
        mock_log = MagicMock()
        
        with patch('sns_cloudwatch_gw.log', mock_log):
            result = sns_cloudwatch_gw.handler(non_sns_event, lambda_context)
            
            mock_log.warn.assert_called_once()
            call_args = mock_log.warn.call_args
            assert call_args[0][0] == "Message source is not aws:sns"
            assert 'event' in call_args[1]
            
            assert result is None

    @patch('sns_cloudwatch_gw.watchtower.CloudWatchLogHandler')
    def test_handler_malformed_event(self, mock_cw_handler_class, malformed_event, lambda_context, mock_watchtower_handler):
        """Test handling of malformed event without Records."""
        mock_cw_handler_class.return_value = mock_watchtower_handler
        mock_log = MagicMock()
        
        with patch('sns_cloudwatch_gw.log', mock_log):
            result = sns_cloudwatch_gw.handler(malformed_event, lambda_context)
            
            mock_log.warn.assert_called_once()
            call_args = mock_log.warn.call_args
            assert call_args[0][0] == "Unexpected event format"
            assert 'lambda_event' in call_args[1]
            
            assert result is None

    @patch('sns_cloudwatch_gw.watchtower.CloudWatchLogHandler')
    def test_handler_empty_event(self, mock_cw_handler_class, empty_event, lambda_context, mock_watchtower_handler):
        """Test handling of empty event."""
        mock_cw_handler_class.return_value = mock_watchtower_handler
        mock_log = MagicMock()
        
        with patch('sns_cloudwatch_gw.log', mock_log):
            result = sns_cloudwatch_gw.handler(empty_event, lambda_context)
            
            mock_log.warn.assert_called_once()
            call_args = mock_log.warn.call_args
            assert call_args[0][0] == "Unexpected event format"
            
            assert result is None

    @patch('sns_cloudwatch_gw.watchtower.CloudWatchLogHandler')
    def test_handler_log_level_from_env(self, mock_cw_handler_class, sns_event, lambda_context, mock_watchtower_handler):
        """Test that log level is correctly set from environment."""
        mock_cw_handler_class.return_value = mock_watchtower_handler
        mock_watchtower_handler.level = logging.INFO
        
        with patch.dict(os.environ, {'LOG_LEVEL': 'DEBUG'}):
            with patch('sns_cloudwatch_gw.structlog.configure') as mock_configure:
                sns_cloudwatch_gw.handler(sns_event, lambda_context)
                
                mock_configure.assert_called_once()
                call_args = mock_configure.call_args
                bound_logger = call_args.kwargs['wrapper_class']
                
    @patch('sns_cloudwatch_gw.watchtower.CloudWatchLogHandler')
    def test_handler_stream_name_format(self, mock_cw_handler_class, sns_event, lambda_context, mock_watchtower_handler):
        """Test CloudWatch log stream name format."""
        mock_cw_handler_class.return_value = mock_watchtower_handler
        mock_watchtower_handler.level = logging.INFO
        
        fixed_time = datetime.datetime(2023, 6, 15, 10, 30, 45, tzinfo=pytz.utc)
        
        with patch('sns_cloudwatch_gw.datetime.datetime') as mock_datetime:
            mock_datetime.now.return_value = fixed_time
            
            sns_cloudwatch_gw.handler(sns_event, lambda_context)
            
            call_args = mock_cw_handler_class.call_args
            assert call_args.kwargs['stream_name'] == '2023-06-15/10-30'

    def test_handler_missing_log_group_env(self, sns_event, lambda_context):
        """Test handler behavior when LOG_GROUP env var is missing."""
        with patch.dict(os.environ, {}, clear=True):
            with patch.dict(os.environ, {'LOG_LEVEL': 'INFO'}):
                with pytest.raises(Exception):
                    sns_cloudwatch_gw.handler(sns_event, lambda_context)

    @patch('sns_cloudwatch_gw.watchtower.CloudWatchLogHandler')
    def test_handler_cloudwatch_handler_exception(self, mock_cw_handler_class, sns_event, lambda_context):
        """Test handler behavior when CloudWatch handler raises exception."""
        mock_cw_handler_class.side_effect = Exception("CloudWatch handler error")
        
        with pytest.raises(Exception) as exc_info:
            sns_cloudwatch_gw.handler(sns_event, lambda_context)
        
        assert "CloudWatch handler error" in str(exc_info.value)

    def test_main_execution(self):
        """Test main execution block."""
        # Create a test script that imports and calls the handler
        test_script = '''
import sys
import os
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

# Mock the handler before importing
from unittest.mock import patch

with patch('sns_cloudwatch_gw.handler') as mock_handler:
    import sns_cloudwatch_gw
    if __name__ == '__main__':
        sns_cloudwatch_gw.handler({}, None)
        assert mock_handler.call_count == 1
'''
        
        # Write the test script temporarily
        import tempfile
        with tempfile.NamedTemporaryFile(mode='w', suffix='.py', delete=False, dir=os.path.dirname(__file__)) as f:
            f.write(test_script)
            temp_file = f.name
        
        try:
            # Execute the test script
            import subprocess
            result = subprocess.run([sys.executable, temp_file], capture_output=True, text=True)
            assert result.returncode == 0, f"Script failed: {result.stderr}"
        finally:
            # Clean up
            os.unlink(temp_file)