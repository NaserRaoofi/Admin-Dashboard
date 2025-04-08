output "widgets" {
  description = "RDS monitoring widgets"
  value       = local.rds_widgets
}

output "alarm_arns" {
  description = "ARNs of the RDS alarms"
  value       = [
    aws_cloudwatch_metric_alarm.high_cpu_rds.arn,
    aws_cloudwatch_metric_alarm.low_storage.arn
  ]
} 