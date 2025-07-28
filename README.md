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
  - Python dependencies packages in Lambda Layers zip
- Optionally create custom Lambda Layer zip using [build-lambda-layer-python](https://github.com/robertpeteuil/build-lambda-layer-python)
  - Enables adding/changing dependencies
  - Enables compiling for different version of Python



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


<!-- BEGIN_TF_DOCS -->
# Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~>  1.0 |
| <a name="requirement_archive"></a> [archive](#requirement\_archive) | ~>2.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.0 |

# Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_create_log_group"></a> [create\_log\_group](#input\_create\_log\_group) | Boolean flag that determines if log group, 'log\_group\_name' is created.  If 'false' it uses an existing group of that name. | `bool` | `true` | no |
| <a name="input_create_sns_topic"></a> [create\_sns\_topic](#input\_create\_sns\_topic) | Boolean flag that determines if SNS topic, 'sns\_topic\_name' is created. If 'false' it uses an existing topic of that name. | `bool` | `true` | no |
| <a name="input_create_warmer_event"></a> [create\_warmer\_event](#input\_create\_warmer\_event) | Boolean flag that determines if a CloudWatch Trigger event is created to prevent Lambda function from suspending. | `bool` | `false` | no |
| <a name="input_lambda_description"></a> [lambda\_description](#input\_lambda\_description) | Description to assign to Lambda Function. | `string` | `""` | no |
| <a name="input_lambda_func_name"></a> [lambda\_func\_name](#input\_lambda\_func\_name) | Name to assign to Lambda Function. | `string` | `"SNStoCloudWatchLogs"` | no |
| <a name="input_lambda_mem_size"></a> [lambda\_mem\_size](#input\_lambda\_mem\_size) | Amount of RAM (in MB) assigned to the function. The default (and minimum) is 128MB, and the maximum is 3008MB. | `number` | `128` | no |
| <a name="input_lambda_publish_func"></a> [lambda\_publish\_func](#input\_lambda\_publish\_func) | Boolean flag that determines if Lambda function is published as a version. | `bool` | `false` | no |
| <a name="input_lambda_runtime"></a> [lambda\_runtime](#input\_lambda\_runtime) | Lambda runtime to use for the function. | `string` | `"python3.8"` | no |
| <a name="input_lambda_timeout"></a> [lambda\_timeout](#input\_lambda\_timeout) | Number of seconds that the function can run before timing out. The AWS default is 3s and the maximum runtime is 5m | `number` | `3` | no |
| <a name="input_log_group_name"></a> [log\_group\_name](#input\_log\_group\_name) | Name of CloudWatch Log Group created or used (if previously created). | `string` | n/a | yes |
| <a name="input_log_group_retention_days"></a> [log\_group\_retention\_days](#input\_log\_group\_retention\_days) | Number of days to retain data in the log group (0 = always retain). | `number` | `0` | no |
| <a name="input_sns_topic_name"></a> [sns\_topic\_name](#input\_sns\_topic\_name) | Name of SNS Topic logging to CloudWatch Log. | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | A mapping of tags to assign to Lambda Function. | `map` | `{}` | no |

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
