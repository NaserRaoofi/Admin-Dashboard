locals {
  elb_widgets = [
    {
      type   = "metric"
      x      = 0
      y      = 36
      width  = 12
      height = 6
      properties = {
        metrics = [["AWS/ApplicationELB", "HTTPCode_ELB_5XX_Count", "LoadBalancer", "*"]]
        period  = var.monitoring_period
        stat    = "Sum"
        region  = var.aws_region
        title   = "ELB 5XX Errors"
        annotations = {
          horizontal = [
            {
              label = "Error Threshold"
              value = var.error_threshold
            }
          ]
        }
      }
    },
    {
      type   = "metric"
      x      = 12
      y      = 36
      width  = 12
      height = 6
      properties = {
        metrics = [["AWS/ApplicationELB", "TargetResponseTime", "LoadBalancer", "*"]]
        period  = var.monitoring_period
        stat    = "Average"
        region  = var.aws_region
        title   = "Target Response Time"
        annotations = {
          horizontal = [
            {
              label = "Response Time Threshold"
              value = var.response_time_threshold
            }
          ]
        }
      }
    }
  ]
}

resource "aws_cloudwatch_metric_alarm" "high_5xx_errors" {
  alarm_name          = "elb-high-5xx-errors"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "HTTPCode_ELB_5XX_Count"
  namespace           = "AWS/ApplicationELB"
  period             = "300"
  statistic          = "Sum"
  threshold          = var.error_threshold
  alarm_description  = "This metric monitors ELB 5XX errors"
  alarm_actions      = [var.sns_topic_arn]
}

resource "aws_cloudwatch_metric_alarm" "high_response_time" {
  alarm_name          = "elb-high-response-time"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "TargetResponseTime"
  namespace           = "AWS/ApplicationELB"
  period             = "300"
  statistic          = "Average"
  threshold          = var.response_time_threshold
  alarm_description  = "This metric monitors ELB target response time"
  alarm_actions      = [var.sns_topic_arn]
} 