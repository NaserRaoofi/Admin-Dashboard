locals {
  lambda_widgets = [
    {
      type   = "metric"
      x      = 0
      y      = 24
      width  = 8
      height = 6
      properties = {
        metrics = [["AWS/Lambda", "Errors", "FunctionName", "*"]]
        period  = var.monitoring_period
        stat    = "Sum"
        region  = var.aws_region
        title   = "Lambda Errors"
      }
    },
    {
      type   = "metric"
      x      = 8
      y      = 24
      width  = 8
      height = 6
      properties = {
        metrics = [["AWS/Lambda", "Duration", "FunctionName", "*"]]
        period  = var.monitoring_period
        stat    = "Average"
        region  = var.aws_region
        title   = "Lambda Duration"
      }
    },
    {
      type   = "metric"
      x      = 16
      y      = 24
      width  = 8
      height = 6
      properties = {
        metrics = [["AWS/Lambda", "Throttles", "FunctionName", "*"]]
        period  = var.monitoring_period
        stat    = "Sum"
        region  = var.aws_region
        title   = "Lambda Throttles"
      }
    }
  ]
}

resource "aws_cloudwatch_metric_alarm" "lambda_errors" {
  alarm_name          = "lambda-high-error-rate"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "Errors"
  namespace           = "AWS/Lambda"
  period             = "300"
  statistic          = "Sum"
  threshold          = var.error_threshold
  alarm_description  = "This metric monitors Lambda function errors"
  alarm_actions      = [var.sns_topic_arn]
}

resource "aws_cloudwatch_metric_alarm" "lambda_duration" {
  alarm_name          = "lambda-long-duration"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "Duration"
  namespace           = "AWS/Lambda"
  period             = "300"
  statistic          = "Average"
  threshold          = var.duration_threshold
  alarm_description  = "This metric monitors Lambda function duration"
  alarm_actions      = [var.sns_topic_arn]
} 