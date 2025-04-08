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

variable "max_bucket_size_bytes" {
  description = "Maximum bucket size in bytes before alerting"
  type        = number
  default     = 107374182400  # 100GB in bytes
} 