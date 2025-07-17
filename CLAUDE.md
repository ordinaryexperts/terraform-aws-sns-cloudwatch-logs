# terraform-aws-sns-cloudwatch-logs Project Memory

## Overview
Terraform module that creates an AWS Lambda function to route SNS messages to CloudWatch Logs. The Lambda function is written in Python and processes SNS events, writing message content to specified CloudWatch Log Groups.

## Repository Structure
```
terraform-aws-sns-cloudwatch-logs/
├── function/                    # Lambda function code
│   ├── pyproject.toml          # Python project config (PEP 621, uv package manager)
│   ├── uv.lock                 # Dependency lock file
│   ├── sns_cloudwatch_gw.py    # Main Lambda handler
│   ├── lambda_sns_cloudwatch_logs/  # Python package
│   └── tests/                  # Unit tests (pytest)
├── .github/workflows/
│   └── ci.yml                  # GitHub Actions CI (Terraform validation, Python tests)
├── *.tf                        # Terraform configuration files
└── Makefile                    # Build automation
```

## Key Components

### Lambda Function
- **Handler**: `sns_cloudwatch_gw.handler`
- **Runtime**: Python 3.9
- **Purpose**: Routes SNS messages to CloudWatch Logs
- **Dependencies**: watchtower (CloudWatch integration), structlog (structured logging)
- **Environment Variables**:
  - `LOG_GROUP` (required): Target CloudWatch Log Group
  - `LOG_LEVEL` (optional): Logging verbosity

### Development Workflow
- **Package Manager**: uv (fast Python package manager)
- **Testing**: pytest with 97% code coverage
- **Code Quality**: black (formatting), mypy (type checking)
- **CI/CD**: GitHub Actions runs tests on PR

### Build Process
- `make test`: Run Python tests with uv
- `make lambda_layer`: Generate requirements.txt and build Lambda layer
- Tests must pass before merging PRs

## Important Notes
- Project uses uv instead of Poetry for dependency management
- All Python dependencies are in `function/pyproject.toml`
- CI validates both Terraform and Python code
- Lambda deployment layer build script (`_build_layer/build_layer.sh`) is referenced but missing

## Common Commands
```bash
# Install dependencies
cd function && uv sync --all-extras

# Run tests
cd function && uv run pytest

# Format code
cd function && uv run black .

# Type check
cd function && uv run mypy .
```

## Recent Updates
- **2025-07-17**: Migrated from Poetry to uv package manager for improved performance
- **2025-07-17**: Updated to Python 3.9 with refreshed dependencies
- **2025-07-17**: Added comprehensive unit test suite