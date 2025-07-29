# -----------------------------------------------------------------
# REQUIRED VARIABLES WITHOUT DEFAULT VALUES
# -----------------------------------------------------------------

variable "sns_topic_name" {
  type        = string
  description = "Name of SNS Topic logging to CloudWatch Log."
}

variable "log_group_name" {
  type        = string
  description = "Name of CloudWatch Log Group created or used (if previously created)."
}

# -----------------------------------------------------------------
# VARIABLES DEFINITIONS WITH DEFAULT VALUES
# -----------------------------------------------------------------

# SNS TOPIC, LOG GROUP, LOG STREAM

variable "create_sns_topic" {
  type        = bool
  default     = true
  description = "Whether to create a new SNS topic. If false, uses an existing topic with the name specified in sns_topic_name."
}

variable "create_log_group" {
  type        = bool
  default     = true
  description = "Whether to create a new CloudWatch Log Group. If false, uses an existing log group with the name specified in log_group_name."
}

variable "log_group_retention_days" {
  type        = number
  default     = 0
  description = "Number of days to retain data in the log group (0 = always retain)."
  validation {
    condition     = contains([0, 1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1096, 1827, 2192, 2557, 2922, 3288, 3653], var.log_group_retention_days)
    error_message = "The log_group_retention_days must be one of the allowed values: 0, 1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1096, 1827, 2192, 2557, 2922, 3288, 3653."
  }
}

# LAMBDA FUNCTION

variable "lambda_func_name" {
  type        = string
  default     = "SNStoCloudWatchLogs"
  description = "Name to assign to Lambda Function."
}

variable "lambda_description" {
  type        = string
  default     = ""
  description = "Description to assign to Lambda Function."
}

variable "lambda_publish_func" {
  type        = bool
  default     = false
  description = "Whether to publish the Lambda function as a version."
}

variable "create_warmer_event" {
  type        = bool
  default     = false
  description = "Whether to create a CloudWatch Events rule to periodically invoke the Lambda function to prevent cold starts."
}

variable "lambda_timeout" {
  type        = number
  default     = 3
  description = "Lambda function timeout in seconds. AWS default is 3 seconds, maximum is 300 seconds (5 minutes)."
  validation {
    condition     = var.lambda_timeout >= 1 && var.lambda_timeout <= 300
    error_message = "The lambda_timeout must be between 1 and 300 seconds (5 minutes)."
  }
}

variable "lambda_mem_size" {
  type        = number
  default     = 128
  description = "Lambda function memory size in MB. Must be between 128 MB and 3008 MB in 64 MB increments."
  validation {
    condition     = var.lambda_mem_size >= 128 && var.lambda_mem_size <= 3008 && var.lambda_mem_size % 64 == 0
    error_message = "The lambda_mem_size must be between 128 and 3008 MB, in 64 MB increments."
  }
}

variable "log_stream_format" {
  type        = string
  default     = "%Y-%m-%d/%H00"
  description = "Python strftime format string for CloudWatch log stream names. Default creates hourly streams (e.g., 2025-07-29/0600)."
}

variable "tags" {
  type        = map(string)
  description = "Map of tags to assign to all created resources."
  default     = {}
}
