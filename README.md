terraform-aws-sns-cloudwatch-logs
=================================

[![Latest Release](https://img.shields.io/github/release/ordinaryexperts/terraform-aws-sns-cloudwatch-logs.svg)](https://github.com/ordinaryexperts/terraform-aws-sns-cloudwatch-logs) [![license](https://img.shields.io/github/license/ordinaryexperts/terraform-aws-sns-cloudwatch-logs.svg?colorB=2067b8)](https://github.com/ordinaryexperts/terraform-aws-sns-cloudwatch-logs)

`terraform-aws-sns-cloudwatch-logs` is a Terraform module for provisioning a
Lambda function that routes SNS messages to CloudWatch Logs.



Terraform Module Features
-------------------------

This Module allows simple and rapid deployment

- Creates Lambda function, Lambda Layer, IAM Policies, Triggers, and Subscriptions
- Creates (or use existing) SNS Topic and CloudWatch Log Group
- Options:
  - Create CloudWatch Event to prevent Function hibernation
  - Set Log Group retention period
- Python function editable in repository and in Lambda UI
  - Python dependencies packaged in Lambda Layer zip
- Lambda Layer build system using AWS SAM CLI Docker images
  - Enables adding/changing dependencies
  - Pre-built layer included for Python 3.12



SNS to CloudWatch Logs Features
-------------------------------

This Lambda Function forwards SNS messages to a CloudWatch Log Group.  

- Enhances the value of CloudWatch Logs by enabling easy entry creation from any service, function and script that can send SNS notifications
- Enables cloud-init, bootstraps and functions to easily write log entries to a centralized CloudWatch Log
- Simplifies troubleshooting of solutions with decentralized logic
  - scripts and functions spread across instances, Lambda and services
- Easily add instrumentation to scripts: `aws sns publish --topic-arn $TOPIC_ARN --message $LOG_ENTRY`
  - Use with IAM instance policy requires `--region $AWS_REGION` parameter



Usage
-----

```hcl
module "sns_logger" {
  source            = "ordinaryexperts/sns-cloudwatch-logs/aws"
  version           = "~> 5.2"

  sns_topic_name    = "projectx-logging"
  log_group_name    = "projectx"
}
```

> NOTE: Make sure you are using [version pinning](https://www.terraform.io/docs/modules/usage.html#module-versions) to avoid unexpected changes when the module is updated.


Contributing
------------

### Building the Lambda Layer

This module includes a pre-built Lambda layer (`base_python3.12.zip`) containing all Python dependencies. The layer must be rebuilt and committed to the repository when:

- Upgrading Python dependencies in `function/pyproject.toml`
- Changing the Python runtime version
- Adding or removing dependencies

#### Prerequisites

- Docker installed and running
- [uv](https://github.com/astral-sh/uv) installed (for dependency management)
- Write access to the repository

#### Build Process

1. **Build the layer**:
   ```bash
   make lambda_layer
   # or directly:
   ./build_layer.sh
   ```

2. **Test the changes**:
   ```bash
   make test
   ```

3. **Commit the updated layer**:
   ```bash
   git add base_python3.12.zip
   git commit -m "chore: Update Lambda layer with new dependencies"
   ```

#### How it Works

The build script (`build_layer.sh`):
1. Detects or generates a `requirements.txt` from `function/pyproject.toml` using `uv pip compile`
2. Uses AWS SAM CLI Docker image (`public.ecr.aws/sam/build-python3.12:latest`) to install dependencies
3. Creates a Lambda-compatible zip file with dependencies in the correct directory structure
4. Validates the layer size against AWS Lambda limits (250MB unzipped)

#### Important Notes

- The pre-built layer **must be committed** to the repository for the Terraform module to work
- The layer is built for a specific Python version (currently 3.12) and must match the Lambda runtime
- Binary files in Git increase repository size, but this is necessary for module distribution
- Always rebuild the layer when updating dependencies to ensure compatibility


<!-- BEGIN_TF_DOCS -->
# Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~>  1.0 |
| <a name="requirement_archive"></a> [archive](#requirement\_archive) | ~> 2.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.0 |

# Providers

| <a name="output_lambda_last_modified"></a> [lambda\_last\_modified](#output\_lambda\_last\_modified) | The date Lambda Function was last modified. |
| <a name="output_lambda_name"></a> [lambda\_name](#output\_lambda\_name) | Name assigned to Lambda Function. |
| <a name="output_lambda_version"></a> [lambda\_version](#output\_lambda\_version) | Latest published version of Lambda Function. |
| <a name="output_log_group_arn"></a> [log\_group\_arn](#output\_log\_group\_arn) | ARN of CloudWatch Log Group. |
| <a name="output_log_group_name"></a> [log\_group\_name](#output\_log\_group\_name) | Name of CloudWatch Log Group. |
| <a name="output_sns_topic_arn"></a> [sns\_topic\_arn](#output\_sns\_topic\_arn) | ARN of SNS Topic logging to CloudWatch Log. |
| <a name="output_sns_topic_name"></a> [sns\_topic\_name](#output\_sns\_topic\_name) | Name of SNS Topic logging to CloudWatch Log. |
<!-- END_TF_DOCS -->


History
-------

This module was derived from the [Trussworks fork] of [Robert Peteuil]'s
[`terraform-aws-sns-to-cloudwatch-logs-lambda`][original].


[Trussworks fork]: https://github.com/trussworks/terraform-aws-sns-to-cloudwatch-logs-lambda
[Robert Peteuil]: https://github.com/robertpeteuil
[original]: https://github.com/robertpeteuil/terraform-aws-sns-to-cloudwatch-logs-lambda
