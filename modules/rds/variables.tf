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

variable "min_free_storage_space" {
  description = "Minimum free storage space in bytes before alerting"
  type        = number
  default     = 10737418240  # 10GB in bytes
} 