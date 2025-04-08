output "widgets" {
  description = "Cost monitoring widgets"
  value       = local.cost_widgets
}

output "alarm_arns" {
  description = "ARNs of the Cost alarms"
  value       = [
    aws_cloudwatch_metric_alarm.billing_threshold.arn,
    aws_cloudwatch_metric_alarm.daily_spend_anomaly.arn
  ]
} 