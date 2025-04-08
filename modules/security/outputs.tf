output "widgets" {
  description = "Security monitoring widgets"
  value       = local.security_widgets
}

output "alarm_arns" {
  description = "ARNs of the Security alarms"
  value       = [aws_cloudwatch_metric_alarm.iam_changes.arn]
} 