output "widgets" {
  description = "ELB monitoring widgets"
  value       = local.elb_widgets
}

output "alarm_arns" {
  description = "ARNs of the ELB alarms"
  value       = [
    aws_cloudwatch_metric_alarm.high_5xx_errors.arn,
    aws_cloudwatch_metric_alarm.high_response_time.arn
  ]
} 