# -------------------------------------------------------------------------------------
# CREATE IAM ROLE AND POLICIES FOR LAMBDA FUNCTION
# -------------------------------------------------------------------------------------

locals {
  iam_role_name = "lambda-${lower(var.lambda_func_name)}-${local.region}"
}

# Create IAM role
resource "aws_iam_role" "lambda_cloudwatch_logs" {
  name               = local.iam_role_name
  assume_role_policy = data.aws_iam_policy_document.lambda_cloudwatch_logs.json

  tags = var.tags
}

# Add base Lambda Execution policy
resource "aws_iam_role_policy" "lambda_cloudwatch_logs_policy" {
  name   = local.iam_role_name
  role   = aws_iam_role.lambda_cloudwatch_logs.id
  policy = data.aws_iam_policy_document.lambda_cloudwatch_logs_policy.json
}

# JSON POLICY - assume role
data "aws_iam_policy_document" "lambda_cloudwatch_logs" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

# JSON POLICY - base Lambda Execution policy
data "aws_iam_policy_document" "lambda_cloudwatch_logs_policy" {
  statement {
    actions = [
      "logs:CreateLogStream",
      "logs:CreateLogGroup",
      "logs:PutLogEvents",
    ]

    resources = [
      local.log_group_arn,
      "${local.log_group_arn}:*"
    ]
  }

}
