"""Pytest fixtures for sns_cloudwatch_gw tests."""

import os
import pytest
from unittest.mock import patch


@pytest.fixture
def sns_event():
    """Sample SNS event."""
    return {
        "Records": [
            {
                "EventSource": "aws:sns",
                "EventVersion": "1.0",
                "EventSubscriptionArn": "arn:aws:sns:us-east-1:123456789012:example-topic:12345678-1234-1234-1234-123456789012",
                "Sns": {
                    "Type": "Notification",
                    "MessageId": "12345678-1234-1234-1234-123456789012",
                    "TopicArn": "arn:aws:sns:us-east-1:123456789012:example-topic",
                    "Subject": "Test Message",
                    "Message": "This is a test log message from SNS",
                    "Timestamp": "2023-01-01T00:00:00.000Z",
                    "SignatureVersion": "1",
                    "Signature": "EXAMPLE",
                    "SigningCertUrl": "EXAMPLE",
                    "UnsubscribeUrl": "EXAMPLE",
                    "MessageAttributes": {}
                }
            }
        ]
    }


@pytest.fixture
def sns_event_multiple_records():
    """SNS event with multiple records."""
    return {
        "Records": [
            {
                "EventSource": "aws:sns",
                "EventVersion": "1.0",
                "EventSubscriptionArn": "arn:aws:sns:us-east-1:123456789012:example-topic:12345678-1234-1234-1234-123456789012",
                "Sns": {
                    "Type": "Notification",
                    "MessageId": "msg-1",
                    "TopicArn": "arn:aws:sns:us-east-1:123456789012:example-topic",
                    "Subject": "Test Message 1",
                    "Message": "First test log message",
                    "Timestamp": "2023-01-01T00:00:00.000Z",
                    "SignatureVersion": "1",
                    "Signature": "EXAMPLE",
                    "SigningCertUrl": "EXAMPLE",
                    "UnsubscribeUrl": "EXAMPLE",
                    "MessageAttributes": {}
                }
            },
            {
                "EventSource": "aws:sns",
                "EventVersion": "1.0",
                "EventSubscriptionArn": "arn:aws:sns:us-east-1:123456789012:example-topic:12345678-1234-1234-1234-123456789012",
                "Sns": {
                    "Type": "Notification",
                    "MessageId": "msg-2",
                    "TopicArn": "arn:aws:sns:us-east-1:123456789012:example-topic",
                    "Subject": "Test Message 2",
                    "Message": "Second test log message",
                    "Timestamp": "2023-01-01T00:00:01.000Z",
                    "SignatureVersion": "1",
                    "Signature": "EXAMPLE",
                    "SigningCertUrl": "EXAMPLE",
                    "UnsubscribeUrl": "EXAMPLE",
                    "MessageAttributes": {}
                }
            }
        ]
    }


@pytest.fixture
def non_sns_event():
    """Non-SNS event (e.g., S3 event)."""
    return {
        "Records": [
            {
                "EventSource": "aws:s3",
                "eventVersion": "2.1",
                "eventSource": "aws:s3",
                "awsRegion": "us-east-1",
                "eventTime": "2023-01-01T00:00:00.000Z",
                "eventName": "ObjectCreated:Put",
                "s3": {
                    "bucket": {
                        "name": "example-bucket"
                    },
                    "object": {
                        "key": "example-object"
                    }
                }
            }
        ]
    }


@pytest.fixture
def malformed_event():
    """Malformed event missing Records."""
    return {
        "NotRecords": "This is not a valid event structure"
    }


@pytest.fixture
def empty_event():
    """Empty event."""
    return {}


@pytest.fixture
def lambda_context():
    """Mock Lambda context."""
    class LambdaContext:
        def __init__(self):
            self.function_name = "test-function"
            self.function_version = "$LATEST"
            self.invoked_function_arn = "arn:aws:lambda:us-east-1:123456789012:function:test-function"
            self.memory_limit_in_mb = "128"
            self.aws_request_id = "test-request-id"
            self.log_group_name = "/aws/lambda/test-function"
            self.log_stream_name = "2023/01/01/[$LATEST]abcdef1234567890"
            self.remaining_time_in_millis = lambda: 300000
    
    return LambdaContext()


@pytest.fixture(autouse=True)
def mock_environment():
    """Mock environment variables."""
    with patch.dict(os.environ, {
        'LOG_GROUP': 'test-log-group',
        'LOG_LEVEL': 'INFO'
    }):
        yield


@pytest.fixture
def mock_watchtower_handler(mocker):
    """Mock CloudWatch handler."""
    mock_handler = mocker.MagicMock()
    mock_handler.flush = mocker.MagicMock()
    mock_handler.level = 20  # logging.INFO
    return mock_handler