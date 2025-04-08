locals {
  rds_widgets = [
    {
      type   = "metric"
      x      = 0
      y      = 12
      width  = 8
      height = 6
      properties = {
        metrics = [["AWS/RDS", "CPUUtilization", "DBInstanceIdentifier", "*"]]
        period  = var.monitoring_period
        stat    = "Average"
        region  = var.aws_region
        title   = "RDS CPU Utilization"
      }
    },
    {
      type   = "metric"
      x      = 8
      y      = 12
      width  = 8
      height = 6
      properties = {
        metrics = [["AWS/RDS", "FreeStorageSpace", "DBInstanceIdentifier", "*"]]
        period  = var.monitoring_period
        stat    = "Average"
        region  = var.aws_region
        title   = "RDS Free Storage Space"
      }
    },
    {
      type   = "metric"
      x      = 16
      y      = 12
      width  = 8
      height = 6
      properties = {
        metrics = [["AWS/RDS", "DatabaseConnections", "DBInstanceIdentifier", "*"]]
        period  = var.monitoring_period
        stat    = "Sum"
        region  = var.aws_region
        title   = "RDS Database Connections"
      }
    }
  ]
}

resource "aws_cloudwatch_metric_alarm" "high_cpu_rds" {
  alarm_name          = "rds-high-cpu-utilization"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/RDS"
  period             = "300"
  statistic          = "Average"
  threshold          = "80"
  alarm_description  = "This metric monitors RDS CPU utilization"
  alarm_actions      = [var.sns_topic_arn]
}

resource "aws_cloudwatch_metric_alarm" "low_storage" {
  alarm_name          = "rds-low-storage"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "FreeStorageSpace"
  namespace           = "AWS/RDS"
  period             = "300"
  statistic          = "Average"
  threshold          = var.min_free_storage_space
  alarm_description  = "This metric monitors RDS free storage space"
  alarm_actions      = [var.sns_topic_arn]
} 