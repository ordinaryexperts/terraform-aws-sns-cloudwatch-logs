"""Unit tests for sns_cloudwatch_gw Lambda function."""

import os
import logging
from pathlib import Path
from unittest.mock import patch, MagicMock
import pytest
import datetime
import pytz
import json

# Add parent directory to Python path for imports
import sys
sys.path.insert(0, str(Path(__file__).parent.parent))

import sns_cloudwatch_gw


def create_mock_logger():
    """Create a mock logger for CloudWatch tests."""
    mock_logger = MagicMock()
    mock_logger.setLevel = MagicMock()
    mock_logger.addHandler = MagicMock()
    mock_logger.info = MagicMock()
    return mock_logger


def setup_cloudwatch_handler_mock(mock_cw_handler_class, mock_watchtower_handler):
    """Set up CloudWatch handler mock with standard configuration."""
    mock_cw_handler_class.return_value = mock_watchtower_handler
    return mock_cw_handler_class


class TestHandler:
    """Test cases for the Lambda handler function.
    
    This test suite covers:
    - SNS event processing (single and multiple records)
    - Non-SNS event handling
    - Malformed event handling  
    - Environment variable configuration
    - CloudWatch log stream naming
    - Exception handling
    - Edge cases (empty messages, large messages, JSON messages)
    """

    @patch('sns_cloudwatch_gw.watchtower.CloudWatchLogHandler')
    def test_handler_sns_event_success(self, mock_cw_handler_class, sns_event, lambda_context, mock_watchtower_handler):
        """Test successful processing of SNS event."""
        setup_cloudwatch_handler_mock(mock_cw_handler_class, mock_watchtower_handler)
        mock_cw_logger = create_mock_logger()
        
        with patch('sns_cloudwatch_gw.logging.getLogger', return_value=mock_cw_logger):
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
        """Test handling of multiple SNS records - should process all records."""
        mock_cw_handler_class.return_value = mock_watchtower_handler
        mock_cw_logger = MagicMock()
        
        with patch('sns_cloudwatch_gw.logging.getLogger') as mock_get_logger:
            mock_get_logger.return_value = mock_cw_logger
            
            result = sns_cloudwatch_gw.handler(sns_event_multiple_records, lambda_context)
            
            # Verify both messages were logged
            assert mock_cw_logger.info.call_count == 2
            mock_cw_logger.info.assert_any_call("First test log message")
            mock_cw_logger.info.assert_any_call("Second test log message")
            
            # Verify flush was called once after all records
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
            assert call_args[0][0] == "Skipping non-SNS record"
            assert 'event_source' in call_args[1]
            assert 'record' in call_args[1]
            
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
            assert call_args[0][0] == "Unexpected event format - missing Records"
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
            assert call_args[0][0] == "Unexpected event format - missing Records"
            
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
                
    @patch('sns_cloudwatch_gw.watchtower.CloudWatchLogHandler')
    def test_handler_stream_name_format(self, mock_cw_handler_class, sns_event, lambda_context, mock_watchtower_handler):
        """Test CloudWatch log stream name format with default (hourly) format."""
        mock_cw_handler_class.return_value = mock_watchtower_handler
        mock_watchtower_handler.level = logging.INFO
        
        fixed_time = datetime.datetime(2023, 6, 15, 10, 30, 45, tzinfo=pytz.utc)
        
        with patch('sns_cloudwatch_gw.datetime.datetime') as mock_datetime:
            mock_datetime.now.return_value = fixed_time
            
            sns_cloudwatch_gw.handler(sns_event, lambda_context)
            
            call_args = mock_cw_handler_class.call_args
            # Default format should now be hourly
            assert call_args.kwargs['stream_name'] == '2023-06-15/1000'
    
    @patch('sns_cloudwatch_gw.watchtower.CloudWatchLogHandler')
    def test_handler_custom_stream_name_format(self, mock_cw_handler_class, sns_event, lambda_context, mock_watchtower_handler):
        """Test CloudWatch log stream name with custom format from environment."""
        mock_cw_handler_class.return_value = mock_watchtower_handler
        mock_watchtower_handler.level = logging.INFO
        
        fixed_time = datetime.datetime(2023, 6, 15, 10, 30, 45, tzinfo=pytz.utc)
        
        with patch.dict(os.environ, {'LOG_STREAM_FORMAT': '%Y/%m/%d/hour-%H'}):
            with patch('sns_cloudwatch_gw.datetime.datetime') as mock_datetime:
                mock_datetime.now.return_value = fixed_time
                
                sns_cloudwatch_gw.handler(sns_event, lambda_context)
                
                call_args = mock_cw_handler_class.call_args
                assert call_args.kwargs['stream_name'] == '2023/06/15/hour-10'

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

    @patch('sns_cloudwatch_gw.watchtower.CloudWatchLogHandler')
    def test_handler_sns_event_with_json_message(self, mock_cw_handler_class, lambda_context, mock_watchtower_handler):
        """Test processing of SNS event with JSON message."""
        json_message = {"level": "ERROR", "message": "Something went wrong", "timestamp": "2023-01-01T00:00:00Z"}
        sns_event_json = {
            "Records": [{
                "EventSource": "aws:sns",
                "Sns": {
                    "Message": json.dumps(json_message)
                }
            }]
        }
        
        mock_cw_handler_class.return_value = mock_watchtower_handler
        mock_cw_logger = MagicMock()
        
        with patch('sns_cloudwatch_gw.logging.getLogger') as mock_get_logger:
            mock_get_logger.return_value = mock_cw_logger
            
            result = sns_cloudwatch_gw.handler(sns_event_json, lambda_context)
            
            mock_cw_logger.info.assert_called_once_with(json.dumps(json_message))
            assert result is None

    @patch('sns_cloudwatch_gw.watchtower.CloudWatchLogHandler')
    def test_handler_empty_sns_message(self, mock_cw_handler_class, lambda_context, mock_watchtower_handler):
        """Test handling of SNS event with empty message."""
        sns_event_empty = {
            "Records": [{
                "EventSource": "aws:sns",
                "Sns": {
                    "Message": ""
                }
            }]
        }
        
        mock_cw_handler_class.return_value = mock_watchtower_handler
        mock_cw_logger = MagicMock()
        
        with patch('sns_cloudwatch_gw.logging.getLogger') as mock_get_logger:
            mock_get_logger.return_value = mock_cw_logger
            
            result = sns_cloudwatch_gw.handler(sns_event_empty, lambda_context)
            
            mock_cw_logger.info.assert_called_once_with("")
            mock_watchtower_handler.flush.assert_called_once()
            assert result is None

    @patch('sns_cloudwatch_gw.watchtower.CloudWatchLogHandler')
    def test_handler_large_message(self, mock_cw_handler_class, lambda_context, mock_watchtower_handler):
        """Test handling of SNS event with large message."""
        large_message = "x" * 10000  # 10KB message
        sns_event_large = {
            "Records": [{
                "EventSource": "aws:sns",
                "Sns": {
                    "Message": large_message
                }
            }]
        }
        
        mock_cw_handler_class.return_value = mock_watchtower_handler
        mock_cw_logger = MagicMock()
        
        with patch('sns_cloudwatch_gw.logging.getLogger') as mock_get_logger:
            mock_get_logger.return_value = mock_cw_logger
            
            result = sns_cloudwatch_gw.handler(sns_event_large, lambda_context)
            
            mock_cw_logger.info.assert_called_once_with(large_message)
            assert result is None

    @patch('sns_cloudwatch_gw.watchtower.CloudWatchLogHandler')  
    def test_handler_flush_exception(self, mock_cw_handler_class, sns_event, lambda_context):
        """Test handler behavior when flush() raises exception."""
        mock_handler = MagicMock()
        mock_handler.flush.side_effect = Exception("Flush failed")
        mock_cw_handler_class.return_value = mock_handler
        
        mock_cw_logger = MagicMock()
        
        with patch('sns_cloudwatch_gw.logging.getLogger') as mock_get_logger:
            mock_get_logger.return_value = mock_cw_logger
            
            # The handler doesn't catch flush exceptions, so it should propagate
            with pytest.raises(Exception) as exc_info:
                sns_cloudwatch_gw.handler(sns_event, lambda_context)
            
            assert "Flush failed" in str(exc_info.value)
            mock_cw_logger.info.assert_called_once()

    @patch('sns_cloudwatch_gw.watchtower.CloudWatchLogHandler')
    def test_handler_records_without_eventsource(self, mock_cw_handler_class, lambda_context, mock_watchtower_handler):
        """Test handling of event with Records but missing EventSource."""
        event_no_source = {
            "Records": [{
                "Sns": {
                    "Message": "Test message"
                }
            }]
        }
        
        mock_cw_handler_class.return_value = mock_watchtower_handler
        mock_log = MagicMock()
        
        with patch('sns_cloudwatch_gw.log', mock_log):
            result = sns_cloudwatch_gw.handler(event_no_source, lambda_context)
            
            mock_log.warn.assert_called_once()
            call_args = mock_log.warn.call_args
            assert call_args[0][0] == "Unexpected record format - missing EventSource"
            assert 'record' in call_args[1]
            assert result is None

    @pytest.mark.parametrize("env_level,expected_level", [
        ('ERROR', logging.ERROR),
        ('WARNING', logging.WARNING),
        ('DEBUG', logging.DEBUG),
        ('CRITICAL', logging.CRITICAL),
        ('INFO', logging.INFO)
    ])
    @patch('sns_cloudwatch_gw.watchtower.CloudWatchLogHandler')
    def test_handler_different_log_levels(self, mock_cw_handler_class, env_level, expected_level, 
                                         sns_event, lambda_context, mock_watchtower_handler):
        """Test handler with different LOG_LEVEL environment settings."""
        mock_cw_handler_class.return_value = mock_watchtower_handler
        
        with patch.dict(os.environ, {'LOG_LEVEL': env_level}):
            with patch('sns_cloudwatch_gw.env.log_level') as mock_log_level:
                mock_log_level.return_value = expected_level
                
                sns_cloudwatch_gw.handler(sns_event, lambda_context)
                
                mock_log_level.assert_called_with("LOG_LEVEL", logging.INFO)
                
    @pytest.mark.parametrize("message_content,description", [
        ("Simple text message", "plain text"),
        ('{"json": "message"}', "JSON formatted"),
        ("Message with\nnewlines\nand\ttabs", "special characters"),
        ("🚀 Unicode message with emojis 🎉", "unicode characters"),
        ("<xml>HTML/XML content</xml>", "markup content")
    ])
    @patch('sns_cloudwatch_gw.watchtower.CloudWatchLogHandler')
    def test_handler_various_message_types(self, mock_cw_handler_class, message_content, description,
                                         lambda_context, mock_watchtower_handler):
        """Test handler with various message content types."""
        event = {
            "Records": [{
                "EventSource": "aws:sns",
                "Sns": {
                    "Message": message_content
                }
            }]
        }
        
        mock_cw_handler_class.return_value = mock_watchtower_handler
        mock_cw_logger = MagicMock()
        
        with patch('sns_cloudwatch_gw.logging.getLogger') as mock_get_logger:
            mock_get_logger.return_value = mock_cw_logger
            
            result = sns_cloudwatch_gw.handler(event, lambda_context)
            
            mock_cw_logger.info.assert_called_once_with(message_content)
            assert result is None


    @patch('sns_cloudwatch_gw.watchtower.CloudWatchLogHandler')
    def test_handler_mixed_event_sources(self, mock_cw_handler_class, lambda_context, mock_watchtower_handler):
        """Test handling of event with mixed SNS and non-SNS records."""
        mixed_event = {
            "Records": [
                {
                    "EventSource": "aws:sns",
                    "Sns": {
                        "Message": "SNS message 1"
                    }
                },
                {
                    "EventSource": "aws:s3",
                    "s3": {
                        "bucket": {"name": "test-bucket"}
                    }
                },
                {
                    "EventSource": "aws:sns",
                    "Sns": {
                        "Message": "SNS message 2"
                    }
                }
            ]
        }
        
        mock_cw_handler_class.return_value = mock_watchtower_handler
        mock_cw_logger = MagicMock()
        mock_log = MagicMock()
        
        with patch('sns_cloudwatch_gw.logging.getLogger') as mock_get_logger:
            with patch('sns_cloudwatch_gw.log', mock_log):
                mock_get_logger.return_value = mock_cw_logger
                
                result = sns_cloudwatch_gw.handler(mixed_event, lambda_context)
                
                # Should log two SNS messages
                assert mock_cw_logger.info.call_count == 2
                mock_cw_logger.info.assert_any_call("SNS message 1")
                mock_cw_logger.info.assert_any_call("SNS message 2")
                
                # Should warn about one non-SNS record
                mock_log.warn.assert_called_once()
                assert mock_log.warn.call_args[0][0] == "Skipping non-SNS record"
                
                mock_watchtower_handler.flush.assert_called_once()
                assert result is None

    @patch('sns_cloudwatch_gw.watchtower.CloudWatchLogHandler')
    def test_handler_sns_record_missing_message(self, mock_cw_handler_class, lambda_context, mock_watchtower_handler):
        """Test handling of SNS record missing the Message field."""
        event_no_message = {
            "Records": [
                {
                    "EventSource": "aws:sns",
                    "Sns": {
                        "Type": "Notification"
                        # Missing "Message" field
                    }
                }
            ]
        }
        
        mock_cw_handler_class.return_value = mock_watchtower_handler
        mock_log = MagicMock()
        
        with patch('sns_cloudwatch_gw.log', mock_log):
            result = sns_cloudwatch_gw.handler(event_no_message, lambda_context)
            
            mock_log.warn.assert_called_once()
            call_args = mock_log.warn.call_args
            assert call_args[0][0] == "Unexpected SNS record format - missing Sns.Message"
            assert 'record' in call_args[1]
            
            mock_watchtower_handler.flush.assert_called_once()
            assert result is None

    @patch('sns_cloudwatch_gw.watchtower.CloudWatchLogHandler')
    @patch('sns_cloudwatch_gw.logging.getLogger')
    def test_handler_no_double_logging(self, mock_get_logger, mock_cw_handler_class, sns_event, lambda_context, mock_watchtower_handler):
        """Test that SNS messages are not propagated to root logger (no double logging)."""
        # Create both cloudwatch logger and root logger mocks
        mock_cw_logger = create_mock_logger()
        mock_root_logger = create_mock_logger()
        
        # Configure getLogger to return different loggers based on name
        def get_logger_side_effect(name=None):
            if name == "cloudwatch":
                return mock_cw_logger
            return mock_root_logger
            
        mock_get_logger.side_effect = get_logger_side_effect
        setup_cloudwatch_handler_mock(mock_cw_handler_class, mock_watchtower_handler)
        
        # Capture any handlers added to root logger
        root_handlers = []
        mock_root_logger.addHandler.side_effect = lambda h: root_handlers.append(h)
        
        sns_cloudwatch_gw.handler(sns_event, lambda_context)
        
        # Verify SNS message was logged to cloudwatch logger
        mock_cw_logger.info.assert_called_once_with("This is a test log message from SNS")
        
        # Verify root logger did NOT receive the SNS message
        mock_root_logger.info.assert_not_called()
        
        # Verify no handlers were added to root logger for SNS messages
        # This check ensures that the CloudWatch handler is isolated to the "cloudwatch" logger
        # and not inadvertently attached to the root logger, which would cause double logging
        assert len(root_handlers) == 0

    @patch('sns_cloudwatch_gw.watchtower.CloudWatchLogHandler')
    def test_handler_empty_records_list(self, mock_cw_handler_class, lambda_context, mock_watchtower_handler):
        """Test handling of event with empty Records list."""
        empty_records_event = {
            "Records": []
        }
        
        mock_cw_handler_class.return_value = mock_watchtower_handler
        
        result = sns_cloudwatch_gw.handler(empty_records_event, lambda_context)
        
        # Should handle gracefully - just flush without logging anything
        mock_watchtower_handler.flush.assert_called_once()
        assert result is None


class TestMainExecution:
    """Test cases for direct script execution."""
    
    @patch.dict(os.environ, {'LOG_GROUP': 'test-log-group', 'LOG_LEVEL': 'INFO'})
    @patch('sns_cloudwatch_gw.watchtower.CloudWatchLogHandler')
    @patch('sns_cloudwatch_gw.logging.getLogger')
    def test_direct_execution(self, mock_get_logger, mock_cw_handler_class):
        """Test running the module directly with __main__ block."""
        # Set up mocks
        mock_logger = create_mock_logger()
        mock_get_logger.return_value = mock_logger
        mock_handler = MagicMock()
        mock_cw_handler_class.return_value = mock_handler
        
        # Import and execute the module's main block
        import runpy
        
        module_path = Path(__file__).parent.parent / 'sns_cloudwatch_gw.py'
        runpy.run_path(str(module_path), run_name='__main__')
        
        # Verify the handler was created and logger configured
        mock_cw_handler_class.assert_called_once()
        mock_logger.setLevel.assert_called_once_with(logging.INFO)