locals {
  s3_widgets = [
    {
      type   = "metric"
      x      = 0
      y      = 18
      width  = 12
      height = 6
      properties = {
        metrics = [["AWS/S3", "BucketSizeBytes", "BucketName", "*"]]
        period  = var.monitoring_period
        stat    = "Maximum"
        region  = var.aws_region
        title   = "S3 Bucket Sizes"
      }
    },
    {
      type   = "metric"
      x      = 12
      y      = 18
      width  = 12
      height = 6
      properties = {
        metrics = [["AWS/S3", "NumberOfObjects", "BucketName", "*"]]
        period  = var.monitoring_period
        stat    = "Maximum"
        region  = var.aws_region
        title   = "S3 Number of Objects"
      }
    }
  ]
}

resource "aws_cloudwatch_metric_alarm" "bucket_size" {
  alarm_name          = "s3-large-bucket-size"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "BucketSizeBytes"
  namespace           = "AWS/S3"
  period             = "86400"  # Daily check
  statistic          = "Maximum"
  threshold          = var.max_bucket_size_bytes
  alarm_description  = "This metric monitors S3 bucket sizes"
  alarm_actions      = [var.sns_topic_arn]
} 