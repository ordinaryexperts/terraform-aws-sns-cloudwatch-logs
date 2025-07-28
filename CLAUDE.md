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

### Variable Type Improvements (PR #31)
- Added explicit type declarations to all Terraform variables
- Added comprehensive validation rules for constrained inputs:
  - `log_group_retention_days`: Validates against AWS's allowed retention periods
  - `lambda_timeout`: Enforces 1-300 second range
  - `lambda_mem_size`: Validates 128-3008 MB in 64 MB increments
- Converted `lambda_runtime` from variable to local constant (correctly reflects pre-built layer constraint)
- Centralized conditional logic into locals.tf to reduce code duplication
- Fixed typo in IAM resource name (`lambda_cloudwatch_logs_polcy` → `lambda_cloudwatch_logs_policy`)
- Improved IAM security by scoping permissions to specific log group ARN instead of "*"
- Extended tag support to Lambda Layer and CloudWatch Event Rule
- Updated README to reflect removal of lambda_runtime variable

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
- `make lambda_layer` - Build the Lambda layer zip using build_layer.sh
- `make test` - Run Python tests with uv
- CI uses `uv sync --extra dev` and `uv run pytest`

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
- CI workflow updated:
  - Disabled Trufflehog on scheduled runs
  - Python tests now use uv instead of Poetry with Python 3.12
  - Fixed TruffleHog false positives using --only-verified flag
  - TruffleHog job now runs in parallel (removed unnecessary dependency)
  - Simplified job conditionals for better readability
  - All CI checks passing
- Lambda layer must be committed to repository for Terraform module distribution
- README includes comprehensive build documentation

## Recent Changes (2025-01-29)

### Process All SNS Records Enhancement (PR #48)
- **Fixed**: Lambda function now processes ALL records in event["Records"] array
- Previously only processed the first record, potentially dropping messages
- Added comprehensive error handling for malformed records
- Improved code quality with clearer logic flow and descriptive error messages
- Added extensive test coverage for edge cases (mixed event sources, missing fields, empty records)
- Maintained 100% test coverage

## Known Issues
- No error handling for CloudWatch operations
- No retry logic for transient failures
- Lambda function lacks type hints
- CloudWatch stream naming logic could be more configurable