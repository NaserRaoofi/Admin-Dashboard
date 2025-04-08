locals {
  cost_widgets = [
    {
      type   = "metric"
      x      = 0
      y      = 60
      width  = 12
      height = 6
      properties = {
        metrics = [["AWS/Billing", "EstimatedCharges", "ServiceName", "*"]]
        period  = 86400  # Daily granularity
        stat    = "Maximum"
        region  = "us-east-1"  # Billing metrics are only available in us-east-1
        title   = "Estimated Charges by Service"
      }
    },
    {
      type   = "metric"
      x      = 12
      y      = 60
      width  = 12
      height = 6
      properties = {
        metrics = [["AWS/Billing", "EstimatedCharges", "LinkedAccount", "*"]]
        period  = 86400  # Daily granularity
        stat    = "Maximum"
        region  = "us-east-1"  # Billing metrics are only available in us-east-1
        title   = "Estimated Charges by Account"
      }
    },
    {
      type   = "metric"
      x      = 0
      y      = 66
      width  = 24
      height = 6
      properties = {
        metrics = [
          ["AWS/Billing", "EstimatedCharges", "Currency", "USD"]
        ]
        period  = 86400  # Daily granularity
        stat    = "Maximum"
        region  = "us-east-1"  # Billing metrics are only available in us-east-1
        title   = "Total Estimated Charges"
        annotations = {
          horizontal = [
            {
              label = "Monthly Budget"
              value = var.monthly_budget
            },
            {
              label = "Daily Budget"
              value = var.monthly_budget / 30
            }
          ]
        }
      }
    }
  ]
}

resource "aws_cloudwatch_metric_alarm" "billing_threshold" {
  alarm_name          = "billing-threshold-exceeded"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "EstimatedCharges"
  namespace           = "AWS/Billing"
  period             = "86400"  # Daily check
  statistic          = "Maximum"
  threshold          = var.monthly_budget
  alarm_description  = "This metric monitors total estimated AWS charges"
  alarm_actions      = [var.sns_topic_arn]

  dimensions = {
    Currency = "USD"
  }
}

resource "aws_cloudwatch_metric_alarm" "daily_spend_anomaly" {
  alarm_name          = "daily-spend-anomaly"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "EstimatedCharges"
  namespace           = "AWS/Billing"
  period             = "86400"  # Daily check
  statistic          = "Maximum"
  threshold          = var.monthly_budget / 30 * var.daily_threshold_multiplier
  alarm_description  = "This metric monitors for daily spending anomalies"
  alarm_actions      = [var.sns_topic_arn]

  dimensions = {
    Currency = "USD"
  }
} 