output "sns_topic_arn" {
  description = "ARN of the SNS topic for monitoring alerts"
  value       = aws_sns_topic.monitoring_alerts.arn
}

output "enabled_services" {
  description = "List of AWS services being monitored"
  value       = var.available_services
}

output "monitoring_period" {
  description = "Monitoring period in seconds"
  value       = var.monitoring_period
}

output "monthly_budget" {
  description = "Monthly budget for AWS services"
  value       = var.monthly_budget
} 