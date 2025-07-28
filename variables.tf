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
  description = "Boolean flag that determines if SNS topic, 'sns_topic_name' is created. If 'false' it uses an existing topic of that name."
}

variable "create_log_group" {
  type        = bool
  default     = true
  description = "Boolean flag that determines if log group, 'log_group_name' is created.  If 'false' it uses an existing group of that name."
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
  description = "Boolean flag that determines if Lambda function is published as a version."
}

variable "create_warmer_event" {
  type        = bool
  default     = false
  description = "Boolean flag that determines if a CloudWatch Trigger event is created to prevent Lambda function from suspending."
}

variable "lambda_timeout" {
  type        = number
  default     = 3
  description = "Number of seconds that the function can run before timing out. The AWS default is 3s and the maximum runtime is 5m"
  validation {
    condition     = var.lambda_timeout >= 1 && var.lambda_timeout <= 300
    error_message = "The lambda_timeout must be between 1 and 300 seconds (5 minutes)."
  }
}

variable "lambda_mem_size" {
  type        = number
  default     = 128
  description = "Amount of RAM (in MB) assigned to the function. The default (and minimum) is 128MB, and the maximum is 3008MB."
  validation {
    condition     = var.lambda_mem_size >= 128 && var.lambda_mem_size <= 3008 && var.lambda_mem_size % 64 == 0
    error_message = "The lambda_mem_size must be between 128 and 3008 MB, in 64 MB increments."
  }
}

variable "lambda_runtime" {
  type        = string
  default     = "python3.12"
  description = "Lambda runtime to use for the function."
  validation {
    condition     = contains(["python3.8", "python3.9", "python3.10", "python3.11", "python3.12", "python3.13"], var.lambda_runtime)
    error_message = "The lambda_runtime must be a supported Python runtime version (python3.8 through python3.13)."
  }
}

variable "tags" {
  type        = map(string)
  description = "A mapping of tags to assign to Lambda Function."
  default     = {}
}
