variable "monthly_budget" {
  description = "Monthly budget in USD"
  type        = number
  default     = 1000
}

variable "sns_topic_arn" {
  description = "ARN of the SNS topic for alarm notifications"
  type        = string
}

variable "daily_threshold_multiplier" {
  description = "Multiplier for daily budget threshold (e.g., 1.5 means alert if daily spend is 50% above average)"
  type        = number
  default     = 1.5
} 