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
  description = "Threshold for 5XX errors before alerting"
  type        = number
  default     = 10  # Alert after 10 5XX errors in the evaluation period
}

variable "response_time_threshold" {
  description = "Threshold for target response time (seconds) before alerting"
  type        = number
  default     = 5  # Alert if response time exceeds 5 seconds
} 