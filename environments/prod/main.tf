terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }

  backend "s3" {
    # These will be configured via backend-config during terraform init
    key = "prod/terraform.tfstate"
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Environment = "Production"
      Managed_By = "Terraform"
      Project    = "Admin-Dashboard"
    }
  }
}

# SNS Topic for Alerts
resource "aws_sns_topic" "monitoring_alerts" {
  name = "monitoring-alerts-prod"
}

resource "aws_sns_topic_policy" "default" {
  arn = aws_sns_topic.monitoring_alerts.arn

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowCloudWatchAlarms"
        Effect = "Allow"
        Principal = {
          Service = "cloudwatch.amazonaws.com"
        }
        Action   = "SNS:Publish"
        Resource = aws_sns_topic.monitoring_alerts.arn
      }
    ]
  })
}

# EC2 Monitoring
module "ec2_monitoring" {
  count  = contains(var.available_services, "ec2") ? 1 : 0
  source = "../../modules/ec2"

  aws_region        = var.aws_region
  monitoring_period = var.monitoring_period
  sns_topic_arn    = aws_sns_topic.monitoring_alerts.arn
}

# RDS Monitoring
module "rds_monitoring" {
  count  = contains(var.available_services, "rds") ? 1 : 0
  source = "../../modules/rds"

  aws_region            = var.aws_region
  monitoring_period     = var.monitoring_period
  sns_topic_arn        = aws_sns_topic.monitoring_alerts.arn
  min_free_storage_space = var.rds_storage_threshold_gb * 1024 * 1024 * 1024
}

# S3 Monitoring
module "s3_monitoring" {
  count  = contains(var.available_services, "s3") ? 1 : 0
  source = "../../modules/s3"

  aws_region           = var.aws_region
  monitoring_period    = var.monitoring_period
  sns_topic_arn       = aws_sns_topic.monitoring_alerts.arn
  max_bucket_size_bytes = var.s3_size_threshold_gb * 1024 * 1024 * 1024
}

# Lambda Monitoring
module "lambda_monitoring" {
  count  = contains(var.available_services, "lambda") ? 1 : 0
  source = "../../modules/lambda"

  aws_region         = var.aws_region
  monitoring_period  = var.monitoring_period
  sns_topic_arn     = aws_sns_topic.monitoring_alerts.arn
  error_threshold    = var.lambda_error_threshold
  duration_threshold = 10000  # 10 seconds
}

# ELB Monitoring
module "elb_monitoring" {
  count  = contains(var.available_services, "elasticloadbalancing") ? 1 : 0
  source = "../../modules/elb"

  aws_region             = var.aws_region
  monitoring_period      = var.monitoring_period
  sns_topic_arn         = aws_sns_topic.monitoring_alerts.arn
  error_threshold       = var.elb_5xx_error_threshold
  response_time_threshold = 5
}

# Security Monitoring
module "security_monitoring" {
  count  = contains(var.available_services, "cloudtrail") ? 1 : 0
  source = "../../modules/security"

  aws_region          = var.aws_region
  monitoring_period   = var.monitoring_period
  sns_topic_arn      = aws_sns_topic.monitoring_alerts.arn
  iam_change_threshold = var.iam_change_threshold
}

# Cost Monitoring
module "cost_monitoring" {
  count  = contains(var.available_services, "cloudwatch") ? 1 : 0
  source = "../../modules/cost"

  monthly_budget            = var.monthly_budget
  sns_topic_arn            = aws_sns_topic.monitoring_alerts.arn
  daily_threshold_multiplier = 1.5
}

resource "aws_cloudwatch_dashboard" "main" {
  dashboard_name = var.dashboard_name
  dashboard_body = jsonencode({
    widgets = [
      {
        type = "metric",
        x    = 0,
        y    = 0,
        width = 12,
        height = 6,
        properties = {
          metrics = [
            ["AWS/EC2", "CPUUtilization", "InstanceId", "*"],
            [".", "MemoryUtilization", ".", "*"]
          ],
          period = var.monitoring_period,
          stat   = "Average",
          region = var.aws_region,
          title  = "EC2 Resource Utilization"
        }
      },
      {
        type = "metric",
        x    = 12,
        y    = 0,
        width = 12,
        height = 6,
        properties = {
          metrics = [
            ["AWS/RDS", "FreeStorageSpace", "DBInstanceIdentifier", "*"],
            [".", "DatabaseConnections", ".", "*"]
          ],
          period = var.monitoring_period,
          stat   = "Average",
          region = var.aws_region,
          title  = "RDS Metrics"
        }
      },
      {
        type = "metric",
        x    = 0,
        y    = 6,
        width = 12,
        height = 6,
        properties = {
          metrics = [
            ["AWS/Lambda", "Errors", "FunctionName", "*"],
            [".", "Duration", ".", "*"],
            [".", "Invocations", ".", "*"]
          ],
          period = var.monitoring_period,
          stat   = "Sum",
          region = var.aws_region,
          title  = "Lambda Function Metrics"
        }
      },
      {
        type = "metric",
        x    = 12,
        y    = 6,
        width = 12,
        height = 6,
        properties = {
          metrics = [
            ["AWS/ApplicationELB", "HTTPCode_Target_5XX_Count", "LoadBalancer", "*"],
            [".", "TargetResponseTime", ".", "*"]
          ],
          period = var.monitoring_period,
          stat   = "Sum",
          region = var.aws_region,
          title  = "ELB Metrics"
        }
      },
      {
        type = "metric",
        x    = 0,
        y    = 12,
        width = 24,
        height = 6,
        properties = {
          metrics = [
            ["AWS/S3", "BucketSizeBytes", "BucketName", "*", "StorageType", "StandardStorage"],
            [".", "NumberOfObjects", ".", "*"]
          ],
          period = var.monitoring_period,
          stat   = "Average",
          region = var.aws_region,
          title  = "S3 Storage Metrics"
        }
      }
    ]
  })
}

# CloudWatch Log Groups for each service
resource "aws_cloudwatch_log_group" "ec2_logs" {
  count             = contains(var.available_services, "ec2") ? 1 : 0
  name              = "/aws/ec2/admin-dashboard"
  retention_in_days = 30
}

resource "aws_cloudwatch_log_group" "rds_logs" {
  count             = contains(var.available_services, "rds") ? 1 : 0
  name              = "/aws/rds/admin-dashboard"
  retention_in_days = 30
}

resource "aws_cloudwatch_log_group" "lambda_logs" {
  count             = contains(var.available_services, "lambda") ? 1 : 0
  name              = "/aws/lambda/admin-dashboard"
  retention_in_days = 30
}

# CloudWatch Log Metric Filters
resource "aws_cloudwatch_log_metric_filter" "error_logs" {
  count          = contains(var.available_services, "cloudwatch") ? 1 : 0
  name           = "error-logs"
  pattern        = "ERROR"
  log_group_name = aws_cloudwatch_log_group.ec2_logs[0].name

  metric_transformation {
    name      = "ErrorCount"
    namespace = "CustomMetrics"
    value     = "1"
  }
} 