locals {
  ec2_widgets = [
    {
      type   = "metric"
      x      = 0
      y      = 0
      width  = 12
      height = 6
      properties = {
        metrics = [["AWS/EC2", "CPUUtilization", "InstanceId", "*"]]
        period  = var.monitoring_period
        stat    = "Average"
        region  = var.aws_region
        title   = "EC2 CPU Utilization"
        annotations = {
          horizontal = [
            {
              label = "High CPU Alert"
              value = 80
            }
          ]
        }
      }
    },
    {
      type   = "metric"
      x      = 12
      y      = 0
      width  = 12
      height = 6
      properties = {
        metrics = [["AWS/EC2", "StatusCheckFailed", "InstanceId", "*"]]
        period  = var.monitoring_period
        stat    = "Sum"
        region  = var.aws_region
        title   = "EC2 Status Check Failed"
      }
    },
    {
      type   = "metric"
      x      = 0
      y      = 6
      width  = 24
      height = 6
      properties = {
        metrics = [
          ["AWS/EC2", "NetworkIn", "InstanceId", "*"],
          [".", "NetworkOut", ".", "*"]
        ]
        period  = var.monitoring_period
        stat    = "Average"
        region  = var.aws_region
        title   = "EC2 Network Traffic"
      }
    }
  ]
}

resource "aws_cloudwatch_metric_alarm" "high_cpu" {
  alarm_name          = "high-cpu-utilization"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period             = "300"
  statistic          = "Average"
  threshold          = "80"
  alarm_description  = "This metric monitors EC2 CPU utilization"
  alarm_actions      = [var.sns_topic_arn]
} 