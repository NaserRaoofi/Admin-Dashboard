variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "eu-west-2"
}

variable "monitoring_period" {
  description = "Monitoring period in seconds"
  type        = number
  default     = 300
}

variable "monthly_budget" {
  description = "Monthly budget for AWS services"
  type        = number
  default     = 5000
}

variable "available_services" {
  description = "List of AWS services to monitor"
  type        = list(string)
  default     = ["ec2", "rds", "s3", "lambda", "elasticloadbalancing", "cloudtrail", "cloudwatch", "costexplorer"]
}

# Dashboard configuration
variable "dashboard_name" {
  description = "Name of the CloudWatch dashboard"
  type        = string
  default     = "ProductionAdminDashboard"
}

# Threshold variables for production
variable "rds_storage_threshold_gb" {
  description = "Free storage space threshold for RDS instances in GB"
  type        = number
  default     = 20  # Alert when less than 20GB free space
}

variable "s3_size_threshold_gb" {
  description = "Size threshold for S3 buckets in GB"
  type        = number
  default     = 1000  # Alert when bucket size exceeds 1TB
}

variable "lambda_error_threshold" {
  description = "Error count threshold for Lambda functions"
  type        = number
  default     = 5  # Alert after 5 errors in evaluation period
}

variable "elb_5xx_error_threshold" {
  description = "5XX error count threshold for ELB"
  type        = number
  default     = 10  # Alert after 10 5XX errors
}

variable "iam_change_threshold" {
  description = "Threshold for IAM policy changes in evaluation period"
  type        = number
  default     = 3  # Alert after 3 policy changes
}

# S3 backend configuration
variable "terraform_state_bucket" {
  description = "S3 bucket for storing Terraform state"
  type        = string
}

variable "terraform_state_dynamodb_table" {
  description = "DynamoDB table for Terraform state locking"
  type        = string
}

variable "environment" {
  description = "Environment name (e.g., prod, dev, staging)"
  type        = string
  default     = "prod"
}

variable "enable_advanced_monitoring" {
  description = "Enable advanced monitoring features"
  type        = bool
  default     = false
}

variable "enable_security_hub" {
  description = "Enable AWS Security Hub"
  type        = bool
  default     = false
}

variable "enable_guardduty" {
  description = "Enable AWS GuardDuty"
  type        = bool
  default     = false
}

variable "enable_cloudwatch_agent" {
  description = "Enable CloudWatch agent for detailed monitoring"
  type        = bool
  default     = false
} 