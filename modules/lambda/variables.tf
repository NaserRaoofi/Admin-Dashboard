variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "monitoring_period" {
  description = "Period for monitoring metrics in seconds"
  type        = number
}

variable "sns_topic_arn" {
  description = "ARN of the SNS topic for alarm notifications"
  type        = string
}

variable "error_threshold" {
  description = "Threshold for Lambda function errors before alerting"
  type        = number
  default     = 5  # Alert after 5 errors in the evaluation period
}

variable "duration_threshold" {
  description = "Threshold for Lambda function duration (ms) before alerting"
  type        = number
  default     = 10000  # 10 seconds in milliseconds
} 