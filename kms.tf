resource "aws_kms_key" "lambda" {
  description             = "KMS key for Lambda function ${var.lambda_func_name}"
  deletion_window_in_days = 0
  enable_key_rotation     = true

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "Allow Root Account Full KMS Access"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
        Action   = "kms:*"
        Resource = "*"
      },
      {
        Sid    = "Allow Lambda Role to Decrypt and Describe Key"
        Effect = "Allow"
        Principal = {
          AWS = aws_iam_role.lambda_cloudwatch_logs.arn
        }
        Action = [
          "kms:Decrypt",
          "kms:DescribeKey"
        ]
        Resource = "*"
      }
    ]
  })

  tags = var.tags
}

resource "aws_kms_alias" "lambda" {
  name          = "alias/${var.lambda_func_name}-key"
  target_key_id = aws_kms_key.lambda.key_id
}