# -----------------------------------------------------------------
# CREATE LAMBDA BASE LAYER CONTAINING PYTHON LIBRARIES
# -----------------------------------------------------------------

resource "aws_lambda_layer_version" "logging_base" {
  filename         = "${path.module}/base_${var.lambda_runtime}.zip"
  source_code_hash = filebase64sha256("${path.module}/base_${var.lambda_runtime}.zip")

  layer_name  = "sns-cloudwatch-base-${replace(var.lambda_runtime, ".", "")}"
  description = "python logging and watchtower libraries"

  compatible_runtimes = [var.lambda_runtime]
}
