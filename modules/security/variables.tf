variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "monitoring_period" {
  description = "Period for monitoring metrics in seconds"
  type        = number
  default     = 300
}

variable "sns_topic_arn" {
  description = "ARN of the SNS topic for alarm notifications"
  type        = string
}

variable "evaluation_periods" {
  description = "Number of periods to evaluate for alarm conditions"
  type        = number
  default     = 2
}

variable "iam_change_threshold" {
  description = "Threshold for IAM policy changes before alerting"
  type        = number
  default     = 1
}

variable "failed_login_threshold" {
  description = "Threshold for failed console login attempts"
  type        = number
  default     = 3
}

variable "security_group_change_threshold" {
  description = "Threshold for security group changes"
  type        = number
  default     = 1
}

variable "unauthorized_api_threshold" {
  description = "Threshold for unauthorized API calls"
  type        = number
  default     = 5
}

variable "enable_root_monitoring" {
  description = "Enable monitoring of root account usage"
  type        = bool
  default     = true
}

variable "enable_security_hub" {
  description = "Enable AWS Security Hub integration"
  type        = bool
  default     = true
}

variable "enable_guardduty" {
  description = "Enable AWS GuardDuty integration"
  type        = bool
  default     = true
}

variable "log_retention_days" {
  description = "Number of days to retain CloudWatch logs"
  type        = number
  default     = 90
} 