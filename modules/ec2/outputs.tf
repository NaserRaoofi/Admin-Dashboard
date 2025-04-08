output "widgets" {
  description = "EC2 monitoring widgets"
  value       = local.ec2_widgets
}

output "alarm_arns" {
  description = "ARNs of the EC2 alarms"
  value       = [aws_cloudwatch_metric_alarm.high_cpu.arn]
} 