locals {
  region = data.aws_region.current.name

  # Conditional resource ARNs to reduce repetition
  sns_topic_arn = var.create_sns_topic ? aws_sns_topic.sns_log_topic[0].arn : data.aws_sns_topic.sns_log_topic[0].arn
  log_group_arn = var.create_log_group ? aws_cloudwatch_log_group.sns_logged_item_group[0].arn : data.aws_cloudwatch_log_group.sns_logged_item_group[0].arn
  lambda_arn    = var.lambda_publish_func ? aws_lambda_function.sns_cloudwatchlog.qualified_arn : aws_lambda_function.sns_cloudwatchlog.arn
  region = data.aws_region.current.id
}
