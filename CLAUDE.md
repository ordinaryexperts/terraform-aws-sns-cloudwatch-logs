# terraform-aws-sns-cloudwatch-logs Project Memory

## Project Overview
Terraform module for provisioning a Lambda function that routes SNS messages to CloudWatch Logs.

## Key Components
- **Lambda Function**: Python 3.12 function that receives SNS messages and writes to CloudWatch
- **Lambda Layer**: Contains Python dependencies (boto3, watchtower, structlog, etc.)
- **Build System**: Custom bash script using AWS SAM CLI Docker images
- **Package Manager**: uv (replaced Poetry)
- **Testing**: pytest with 100% coverage

## Recent Changes (2025-01-28)

### Build System Modernization
- Replaced deprecated `robertpeteuil/build-lambda-layer-python` with custom `build_layer.sh` script
- Uses official AWS SAM CLI build images (`public.ecr.aws/sam/build-python3.12:latest`)
- Handles Docker networking issues with `--network host` flag
- Fixes permission issues with `-u $(id -u):$(id -g)` flag

### Python Runtime Upgrade
- Upgraded from Python 3.9 to Python 3.12 (latest AWS Lambda supported version)
- Updated all configuration files and defaults

### Package Manager Migration
- Converted from Poetry to uv for faster, simpler dependency management
- Updated pyproject.toml to standard PEP 621 format
- Added uv.lock for reproducible builds
- Updated build scripts and Makefile

### Dependency Updates
- All Python dependencies updated to latest compatible versions:
  - environs: 14.2.0
  - marshmallow: 3.26.1 (respecting <4.0.0 constraint)
  - pytz: 2025.2
  - structlog: 25.4.0
  - watchtower: 3.4.0

### Terraform Updates
- Updated AWS provider constraint from `~>5.0` to `>=5.0` to support AWS provider v6.x (fixes #32)
- Added explicit provider source declarations

## Build Commands
- `make lambda_layer` - Build the Lambda layer zip
- `make test` - Run Python tests with uv

### Test Suite Improvements
- Achieved 100% test coverage with 16 new test cases
- Added parametrized tests for various message types and log levels
- Improved test organization with helper functions
- Added ruff for code linting
- Fixed all linting issues

### Code Quality Enhancements
- Improved build_layer.sh portability (replaced platform-specific commands)
- Added constants and better error handling
- Enhanced documentation throughout the codebase
- Simplified test implementation

## Important Notes
- Lambda runtime is not configurable - the layer is built for a specific Python version
- The module uses a custom build script that automatically detects Poetry/uv projects
- Docker is required for building the Lambda layer
- PR #41 created for all these changes
- CI workflow updated to disable Trufflehog on scheduled runs

## Known Issues
- Only processes first SNS record (documented with FIXME)
- No error handling for CloudWatch operations
- No retry logic for transient failures