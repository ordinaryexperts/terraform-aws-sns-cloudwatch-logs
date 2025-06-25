# Cinc Auditor Profile for terraform-aws-sns-cloudwatch-logs

This Cinc Auditor profile tests the AWS SNS to CloudWatch Logs Lambda Gateway Terraform module.

## Requirements

- [Cinc Auditor](https://cinc.sh/start/auditor/) or [Chef InSpec](https://www.chef.io/products/chef-inspec/)
- AWS credentials configured
- Deployed infrastructure from the terraform-aws-sns-cloudwatch-logs module

## Profile Structure

- `inspec.yml` - Profile metadata and dependencies
- `controls/sns_cloudwatch_logs.rb` - Main test controls
- `attributes.yml` - Default attribute values

## Controls

The profile includes the following controls:

1. **sns-topic** - Verifies SNS topic exists and configuration
2. **cloudwatch-log-group** - Validates CloudWatch log group setup
3. **lambda-function** - Checks Lambda function configuration (runtime, memory, timeout, handler)
4. **lambda-iam-role** - Verifies Lambda IAM role permissions for CloudWatch Logs
5. **sns-lambda-subscription** - Tests SNS subscription to Lambda function
6. **lambda-permission** - Validates Lambda permission for SNS invocation
7. **lambda-layers** - Checks Lambda layers configuration
8. **lambda-environment-variables** - Verifies required environment variables
9. **lambda-kms-encryption** - Validates KMS encryption setup

## Usage

### With default attributes file

```bash
cinc-auditor exec . --input-file attributes.yml
```

### With custom attributes from Terraform outputs

```bash
cinc-auditor exec . \
  --input sns_topic_name='my-topic' \
  --input log_group_name='/aws/lambda/my-logs' \
  --input lambda_func_name='MyLambdaFunction'
```

### With Terraform state

You can extract values from Terraform state:

```bash
# Get outputs from Terraform
SNS_TOPIC=$(terraform output -raw sns_topic_name)
LOG_GROUP=$(terraform output -raw log_group_name)
LAMBDA_NAME=$(terraform output -raw lambda_name)

# Run tests
cinc-auditor exec . \
  --input sns_topic_name="$SNS_TOPIC" \
  --input log_group_name="$LOG_GROUP" \
  --input lambda_func_name="$LAMBDA_NAME"
```

## Configuration

### Required Inputs

- `sns_topic_name` - Name of the SNS topic
- `log_group_name` - Name of the CloudWatch log group

### Optional Inputs

- `lambda_func_name` - Lambda function name (default: "SNStoCloudWatchLogs")
- `create_sns_topic` - Whether SNS topic was created by module (default: true)
- `create_log_group` - Whether log group was created by module (default: true)
- `lambda_runtime` - Lambda runtime (default: "python3.8")
- `lambda_timeout` - Lambda timeout in seconds (default: 3)
- `lambda_mem_size` - Lambda memory size in MB (default: 128)

## Example Output

```
Profile: SNS to CloudWatch Logs Lambda Gateway Tests (terraform-aws-sns-cloudwatch-logs)
Version: 1.0.0
Target:  aws://us-east-1

  ✔  sns-topic: SNS Topic Configuration
     ✔  SNS Topic example-sns-topic should exist
     ✔  SNS Topic example-sns-topic display_name should eq "example-sns-topic"
  ✔  cloudwatch-log-group: CloudWatch Log Group Configuration
     ✔  CloudWatch Log Group /aws/lambda/sns-cloudwatch-logs should exist
  ✔  lambda-function: Lambda Function Configuration
     ✔  Lambda Function SNStoCloudWatchLogs should exist
     ✔  Lambda Function SNStoCloudWatchLogs runtime should eq "python3.8"
     ✔  Lambda Function SNStoCloudWatchLogs timeout should eq 3
     ✔  Lambda Function SNStoCloudWatchLogs memory_size should eq 128

Profile Summary: 9 successful controls, 0 control failures, 0 controls skipped
Test Summary: 25 successful, 0 failures, 0 skipped
```

## Troubleshooting

### Common Issues

1. **AWS Credentials**: Ensure AWS credentials are configured and have sufficient permissions
2. **Resource Names**: Verify that the input values match your actual deployed resources
3. **Region**: Ensure you're testing in the correct AWS region where resources are deployed

### Required AWS Permissions

The profile requires read permissions for:
- SNS topics and subscriptions
- CloudWatch logs
- Lambda functions and permissions
- IAM roles and policies