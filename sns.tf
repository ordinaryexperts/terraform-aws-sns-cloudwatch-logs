# -----------------------------------------------------------------
# SNS TOPIC
#   create new topic (if create_sns_topic set), else use existing topic
#   arn referenced by "lambda_permssion" and "aws_sns_topic_subscription" 
# -----------------------------------------------------------------

# create if specified
resource "aws_sns_topic" "sns_log_topic" {
  count = var.create_sns_topic ? 1 : 0
  name  = var.sns_topic_name
}

# retrieve topic if not created, arn referenced
data "aws_sns_topic" "sns_log_topic" {
  count = var.create_sns_topic ? 0 : 1
  name  = var.sns_topic_name
}

# -----------------------------------------------------------------
# SUBSCRIBE LAMBDA FUNCTION TO SNS TOPIC
# -----------------------------------------------------------------

resource "aws_sns_topic_subscription" "lambda" {
  topic_arn = var.create_sns_topic ? aws_sns_topic.sns_log_topic[0].arn : data.aws_sns_topic.sns_log_topic[0].arn
  protocol  = "lambda"
  endpoint  = var.lambda_publish_func ? aws_lambda_function.sns_cloudwatchlog.qualified_arn : aws_lambda_function.sns_cloudwatchlog.arn
}
