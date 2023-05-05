# -----------------------------------------------------------------
# REQUIRED VARIABLES WITHOUT DEFAULT VALUES
# -----------------------------------------------------------------

variable "sns_topic_name" {
  type        = string
  description = "Name of SNS Topic logging to CloudWatch Log."
  nullable    = false
}

variable "log_group_name" {
  type        = string
  description = "Name of CloudWatch Log Group created or used (if previously created)."
  nullable    = false
}

# -----------------------------------------------------------------
# VARIABLES DEFINITIONS WITH DEFAULT VALUES
# -----------------------------------------------------------------

# SNS TOPIC, LOG GROUP, LOG STREAM

variable "create_sns_topic" {
  type        = bool
  description = "Should a new SNS topic, 'sns_topic_name', be created? If 'false' it uses an existing topic of that name."
  nullable    = false
  default     = true
}

variable "create_log_group" {
  type        = bool
  description = "Boolean flag that determines if log group, 'log_group_name' is created.  If 'false' it uses an existing group of that name."
  nullable    = false
  default     = true
}

variable "log_group_retention_days" {
  type        = number
  description = "Number of days to retain data in the log group (0 = always retain)."
  nullable    = false
  default     = 0
}

# LAMBDA FUNCTION

variable "lambda_func_name" {
  type        = string
  description = "Name for Lambda function"
  nullable    = false
  default     = "SNStoCloudWatchLogs"
}

variable "lambda_description" {
  type        = string
  description = "Optional description for Lambda function"
  nullable    = true
  default     = null
}

variable "lambda_publish_func" {
  type        = bool
  description = "Should the Lambda function be published as a version?"
  default     = false
  nullable    = false
}

variable "create_warmer_event" {
  type        = bool
  description = "Should a CloudWatch Trigger event be created to prevent Lambda function from suspending?"
  default     = false
  nullable    = false
}

variable "lambda_timeout" {
  type        = number
  description = "Seconds the function can run before timing out. The AWS default is 3s and the maximum runtime is 300s"
  nullable    = false
  default     = 3
}

variable "lambda_mem_size" {
  type        = number
  description = "Amount of RAM (in MB) assigned to the function. The default (and minimum) is 128MB, and the maximum is 3008MB."
  nullable    = false
  default     = 128
}

variable "lambda_runtime" {
  type        = string
  description = "Lambda runtime to use for the function."
  nullable    = false
  default     = "python3.8"
}

variable "lambda_tags" {
  type        = map(string)
  description = "A mapping of tags to assign to Lambda Function."
  nullable    = false
  default     = {}
}
