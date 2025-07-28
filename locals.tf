locals {
  # -----------------------------------------------------------------
  # REGIONAL CONFIGURATION
  # -----------------------------------------------------------------
  region = data.aws_region.current.id

  # -----------------------------------------------------------------
  # LAMBDA CONFIGURATION
  # -----------------------------------------------------------------
  # Runtime is fixed to match the pre-built layer - do not change
  # without rebuilding the layer zip file
  lambda_runtime = "python3.12"

  # -----------------------------------------------------------------
  # RESOURCE ARNS
  # -----------------------------------------------------------------
  # These locals handle the conditional logic for resource creation,
  # selecting between created resources or data sources based on
  # the create_* variables

  sns_topic_arn = var.create_sns_topic ? aws_sns_topic.sns_log_topic[0].arn : data.aws_sns_topic.sns_log_topic[0].arn

  log_group_arn = var.create_log_group ? aws_cloudwatch_log_group.sns_logged_item_group[0].arn : data.aws_cloudwatch_log_group.sns_logged_item_group[0].arn

  lambda_arn = var.lambda_publish_func ? aws_lambda_function.sns_cloudwatchlog.qualified_arn : aws_lambda_function.sns_cloudwatchlog.arn
}
