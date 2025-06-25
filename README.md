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
<!-- END_TF_DOCS -->


History
-------

This module was derived from the [Trussworks fork] of [Robert Peteuil]'s
[`terraform-aws-sns-to-cloudwatch-logs-lambda`][original].


[Trussworks fork]: https://github.com/trussworks/terraform-aws-sns-to-cloudwatch-logs-lambda
[Robert Peteuil]: https://github.com/robertpeteuil
[original]: https://github.com/robertpeteuil/terraform-aws-sns-to-cloudwatch-logs-lambda
