# ----------------------------------------------------------------
# AWS SNS TO CLOUDWATCH LOGS LAMBDA GATEWAY - OUTPUTS
# ----------------------------------------------------------------

output "lambda_name" {
  description = "Name assigned to Lambda Function."
  value       = var.lambda_func_name
}

output "lambda_arn" {
  description = "ARN of created Lambda Function."
  value       = local.lambda_arn
}

output "lambda_version" {
  description = "Latest published version of Lambda Function."
  value       = aws_lambda_function.sns_cloudwatchlog.version
}

output "lambda_last_modified" {
  description = "The date Lambda Function was last modified."
  value       = aws_lambda_function.sns_cloudwatchlog.last_modified
}

output "lambda_iam_role_id" {
  description = "Lambda IAM Role ID."
  value       = aws_iam_role.lambda_cloudwatch_logs.id
}

output "lambda_iam_role_arn" {
  description = "Lambda IAM Role ARN."
  value       = aws_iam_role.lambda_cloudwatch_logs.arn
}

output "sns_topic_name" {
  description = "Name of SNS Topic logging to CloudWatch Log."
  value       = var.sns_topic_name
}

output "sns_topic_arn" {
  description = "ARN of SNS Topic logging to CloudWatch Log."
  value       = local.sns_topic_arn
}

output "log_group_name" {
  description = "Name of CloudWatch Log Group."
  value       = var.log_group_name
}

output "log_group_arn" {
  description = "ARN of CloudWatch Log Group."
  value       = local.log_group_arn
}

output "cloudwatch_event_rule_arn" {
  description = "ARN of CloudWatch Trigger Event created to prevent hibernation."
  value       = var.create_warmer_event ? aws_cloudwatch_event_rule.warmer[0].arn : ""
}
