# Lambda SNS to CloudWatch Logs

This Lambda function forwards SNS messages to CloudWatch Logs.

## Overview

The function processes SNS events and writes the message content to a CloudWatch Log Group, enabling centralized logging from various AWS services and applications that can publish to SNS.

## Function Handler

- **Handler**: `sns_cloudwatch_gw.handler`
- **Runtime**: Python 3.9
- **Architecture**: Uses structlog for structured logging and watchtower for CloudWatch integration

## Environment Variables

- `LOG_GROUP` (required): The CloudWatch Log Group name where messages will be written
- `LOG_LEVEL` (optional): Logging level (default: INFO)

## Development

### Setup

```bash
# Install uv if not already installed
curl -LsSf https://astral.sh/uv/install.sh | sh

# Install dependencies
uv sync --all-extras
```

### Running Tests

```bash
# Run all tests with coverage
uv run pytest

# Run specific test
uv run pytest tests/test_sns_cloudwatch_gw.py::TestHandler::test_handler_sns_event_success

# Generate HTML coverage report
uv run pytest --cov=. --cov-report=html
```

### Code Quality

```bash
# Format code
uv run black .

# Type checking
uv run mypy .
```

## Test Coverage

The test suite covers:
- SNS event processing
- Multiple record handling
- Error scenarios (malformed events, non-SNS sources)
- Environment variable configuration
- CloudWatch logger setup