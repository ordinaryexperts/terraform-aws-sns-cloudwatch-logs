# -----------------------------------------------------------------
# CREATE LAMBDA FUNCTION USING ZIP FILE 
# -----------------------------------------------------------------

# make zip
data "archive_file" "lambda_function" {
  type        = "zip"
  source_file = "${path.module}/function/sns_cloudwatch_gw.py"
  output_path = "${path.module}/lambda.zip"
}

locals {
  dynamic_description = "Routes SNS topic '${var.sns_topic_name}' to CloudWatch group '${var.log_group_name}'"
}

# create lambda using function only zip on top of base layer
resource "aws_lambda_function" "sns_cloudwatchlog" {
  layers = [aws_lambda_layer_version.logging_base.arn]

  function_name = var.lambda_func_name
  description   = length(var.lambda_description) > 0 ? var.lambda_description : local.dynamic_description

  filename         = "${path.module}/lambda.zip"
  source_code_hash = data.archive_file.lambda_function.output_base64sha256

  publish = var.lambda_publish_func ? true : false
  role    = aws_iam_role.lambda_cloudwatch_logs.arn

  runtime     = var.lambda_runtime
  handler     = "sns_cloudwatch_gw.handler"
  timeout     = var.lambda_timeout
  memory_size = var.lambda_mem_size

  kms_key_arn = aws_kms_key.lambda.arn

  environment {
    variables = {
      LOG_GROUP = var.log_group_name
    }
  }

  tags = var.tags
}

# -----------------------------------------------------------------
# ENABLE SNS TOPIC AS LAMBDA FUNCTION TRIGGER
# -----------------------------------------------------------------

# function published - "qualifier" set to function version
resource "aws_lambda_permission" "sns_cloudwatchlog_multi" {
  statement_id  = "AllowExecutionFromSNS"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.sns_cloudwatchlog.function_name
  principal     = "sns.amazonaws.com"
  source_arn    = var.create_sns_topic ? aws_sns_topic.sns_log_topic[0].arn : data.aws_sns_topic.sns_log_topic[0].arn
  qualifier     = var.lambda_publish_func ? aws_lambda_function.sns_cloudwatchlog.version : null
}
