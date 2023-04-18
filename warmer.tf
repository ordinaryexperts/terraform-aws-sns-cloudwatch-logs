# -----------------------------------------------------------------
# CREATE CLOUDWATCH EVENT TO PREVENT LAMBDA FUNCTION SUSPENSION
# -----------------------------------------------------------------

# create cloudwatch event to run every 15 minutes
resource "aws_cloudwatch_event_rule" "warmer" {
  count = var.create_warmer_event ? 1 : 0

  name                = "sns-logger-warmer-${var.sns_topic_name}"
  description         = "Keeps ${var.lambda_func_name} Warm"
  schedule_expression = "rate(15 minutes)"
}

# set event target as sns_to_cloudwatch_logs lambda function 
resource "aws_cloudwatch_event_target" "warmer" {
  count = var.create_warmer_event ? 1 : 0

  # rule      = join("", aws_cloudwatch_event_rule.warmer.*.name)
  rule      = aws_cloudwatch_event_rule.warmer[0].name
  target_id = "Lambda"
  arn       = var.lambda_publish_func ? aws_lambda_function.sns_cloudwatchlog.qualified_arn : aws_lambda_function.sns_cloudwatchlog.arn

  input = <<JSON
{
	"Records": [{
		"EventSource": "aws:events"
	}]
}
JSON
}

# -----------------------------------------------------------------
# ENABLE CLOUDWATCH EVENT AS LAMBDA FUNCTION TRIGGER
# -----------------------------------------------------------------

resource "aws_lambda_permission" "warmer_multi" {
  count = var.create_warmer_event ? 1 : 0

  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.sns_cloudwatchlog.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.warmer[0].arn
  qualifier     = var.lambda_publish_func ? aws_lambda_function.sns_cloudwatchlog.version : null
}
