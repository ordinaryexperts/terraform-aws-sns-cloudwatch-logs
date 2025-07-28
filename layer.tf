# -----------------------------------------------------------------
# CREATE LAMBDA BASE LAYER CONTAINING PYTHON LIBRARIES
# -----------------------------------------------------------------

resource "aws_lambda_layer_version" "logging_base" {
  filename         = "${path.module}/base_${local.lambda_runtime}.zip"
  source_code_hash = filebase64sha256("${path.module}/base_${local.lambda_runtime}.zip")

  layer_name  = "sns-cloudwatch-base-${replace(local.lambda_runtime, ".", "")}"
  description = "python logging and watchtower libraries"

  compatible_runtimes = [local.lambda_runtime]

  tags = var.tags
}
