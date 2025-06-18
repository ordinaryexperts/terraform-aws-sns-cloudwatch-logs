data "aws_kms_key" "lambda" {
  key_id = "alias/aws/lambda"
}
