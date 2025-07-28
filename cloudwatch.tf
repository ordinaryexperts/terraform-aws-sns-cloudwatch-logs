# -----------------------------------------------------------------
# CLOUDWATCH LOG GROUP
#   create new log_group (if create_log_group set)
# -----------------------------------------------------------------

resource "aws_cloudwatch_log_group" "sns_logged_item_group" {
  count             = var.create_log_group ? 1 : 0
  name              = var.log_group_name
  retention_in_days = var.log_group_retention_days

  tags = var.tags
}

# retrieve log group if not created, arn included in outputs
data "aws_cloudwatch_log_group" "sns_logged_item_group" {
  count = var.create_log_group ? 0 : 1
  name  = var.log_group_name
}
