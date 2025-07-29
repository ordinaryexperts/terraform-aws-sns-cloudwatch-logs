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

**Example Usage After Deployment:**

Once the module is deployed, applications and scripts can send logs to CloudWatch by publishing to the created SNS topic:
```bash
aws sns publish --topic-arn $TOPIC_ARN --message $LOG_ENTRY
```
- When using with IAM instance policy, include the `--region $AWS_REGION` parameter



Usage
-----

```hcl
module "sns_logger" {
  source            = "ordinaryexperts/sns-cloudwatch-logs/aws"
  version           = "~> 7.1"

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

| Name | Version |
|------|---------|
| <a name="provider_archive"></a> [archive](#provider\_archive) | ~> 2.0 |
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 5.0 |

# Resources

| Name | Type |
|------|------|
| [aws_cloudwatch_event_rule.warmer](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_rule) | resource |
| [aws_cloudwatch_event_target.warmer](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_target) | resource |
| [aws_cloudwatch_log_group.sns_logged_item_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_iam_role.lambda_cloudwatch_logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.lambda_cloudwatch_logs_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_kms_alias.lambda](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_alias) | resource |
| [aws_kms_key.lambda](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key) | resource |
| [aws_lambda_function.sns_cloudwatchlog](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_function) | resource |
| [aws_lambda_layer_version.logging_base](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_layer_version) | resource |
| [aws_lambda_permission.sns_cloudwatchlog_multi](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_permission) | resource |
| [aws_lambda_permission.warmer_multi](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_permission) | resource |
| [aws_sns_topic.sns_log_topic](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic) | resource |
| [aws_sns_topic_subscription.lambda](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic_subscription) | resource |
| [archive_file.lambda_function](https://registry.terraform.io/providers/hashicorp/archive/latest/docs/data-sources/file) | data source |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_cloudwatch_log_group.sns_logged_item_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/cloudwatch_log_group) | data source |
| [aws_iam_policy_document.lambda_cloudwatch_logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.lambda_cloudwatch_logs_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |
| [aws_sns_topic.sns_log_topic](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/sns_topic) | data source |

# Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_create_log_group"></a> [create\_log\_group](#input\_create\_log\_group) | Whether to create a new CloudWatch Log Group. If false, uses an existing log group with the name specified in log\_group\_name. | `bool` | `true` | no |
| <a name="input_create_sns_topic"></a> [create\_sns\_topic](#input\_create\_sns\_topic) | Whether to create a new SNS topic. If false, uses an existing topic with the name specified in sns\_topic\_name. | `bool` | `true` | no |
| <a name="input_create_warmer_event"></a> [create\_warmer\_event](#input\_create\_warmer\_event) | Whether to create a CloudWatch Events rule to periodically invoke the Lambda function to prevent cold starts. | `bool` | `false` | no |
| <a name="input_lambda_description"></a> [lambda\_description](#input\_lambda\_description) | Description to assign to Lambda Function. | `string` | `""` | no |
| <a name="input_lambda_func_name"></a> [lambda\_func\_name](#input\_lambda\_func\_name) | Name to assign to Lambda Function. | `string` | `"SNStoCloudWatchLogs"` | no |
| <a name="input_lambda_mem_size"></a> [lambda\_mem\_size](#input\_lambda\_mem\_size) | Lambda function memory size in MB. Must be between 128 MB and 3008 MB in 64 MB increments. | `number` | `128` | no |
| <a name="input_lambda_publish_func"></a> [lambda\_publish\_func](#input\_lambda\_publish\_func) | Whether to publish the Lambda function as a version. | `bool` | `false` | no |
| <a name="input_lambda_timeout"></a> [lambda\_timeout](#input\_lambda\_timeout) | Lambda function timeout in seconds. AWS default is 3 seconds, maximum is 300 seconds (5 minutes). | `number` | `3` | no |
| <a name="input_log_group_name"></a> [log\_group\_name](#input\_log\_group\_name) | Name of CloudWatch Log Group created or used (if previously created). | `string` | n/a | yes |
| <a name="input_log_group_retention_days"></a> [log\_group\_retention\_days](#input\_log\_group\_retention\_days) | Number of days to retain data in the log group (0 = always retain). | `number` | `0` | no |
| <a name="input_log_stream_format"></a> [log\_stream\_format](#input\_log\_stream\_format) | Python strftime format string for CloudWatch log stream names. Default creates hourly streams (e.g., 2025-07-29/0600). | `string` | `"%Y-%m-%d/%H00"` | no |
| <a name="input_sns_topic_name"></a> [sns\_topic\_name](#input\_sns\_topic\_name) | Name of SNS Topic logging to CloudWatch Log. | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Map of tags to assign to all created resources. | `map(string)` | `{}` | no |

# Outputs

| Name | Description |
|------|-------------|
| <a name="output_cloudwatch_event_rule_arn"></a> [cloudwatch\_event\_rule\_arn](#output\_cloudwatch\_event\_rule\_arn) | ARN of CloudWatch Trigger Event created to prevent hibernation. |
| <a name="output_lambda_arn"></a> [lambda\_arn](#output\_lambda\_arn) | ARN of created Lambda Function. |
| <a name="output_lambda_iam_role_arn"></a> [lambda\_iam\_role\_arn](#output\_lambda\_iam\_role\_arn) | Lambda IAM Role ARN. |
| <a name="output_lambda_iam_role_id"></a> [lambda\_iam\_role\_id](#output\_lambda\_iam\_role\_id) | Lambda IAM Role ID. |
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
