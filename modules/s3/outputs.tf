output "widgets" {
  description = "S3 monitoring widgets"
  value       = local.s3_widgets
}

output "alarm_arns" {
  description = "ARNs of the S3 alarms"
  value       = [aws_cloudwatch_metric_alarm.bucket_size.arn]
} 