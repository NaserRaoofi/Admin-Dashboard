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

variable "memory_threshold" {
  description = "Memory usage threshold percentage"
  type        = number
  default     = 80
}

variable "cpu_anomaly_band_width" {
  description = "Width of the anomaly detection band (number of standard deviations)"
  type        = number
  default     = 2
}

variable "network_anomaly_band_width" {
  description = "Width of the network anomaly detection band (number of standard deviations)"
  type        = number
  default     = 2
}

variable "disk_io_threshold" {
  description = "Disk I/O threshold in bytes"
  type        = number
  default     = 100000000  # 100MB/s
}

variable "enable_detailed_monitoring" {
  description = "Enable detailed monitoring for EC2 instances"
  type        = bool
  default     = true
}

variable "evaluation_periods" {
  description = "Number of periods to evaluate for alarm conditions"
  type        = number
  default     = 2
}

variable "alarm_actions_enabled" {
  description = "Enable or disable alarm actions"
  type        = bool
  default     = true
} 