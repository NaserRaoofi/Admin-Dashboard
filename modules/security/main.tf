locals {
  security_widgets = [
    # IAM Policy Changes
    {
      type   = "log"
      x      = 0
      y      = 0
      width  = 24
      height = 6
      properties = {
        query   = <<-EOT
          fields @timestamp, eventName, userIdentity.userName, eventSource, errorCode, requestParameters.policyName
          | filter eventSource like /iam/
          | filter eventName like /(Create|Update|Delete|Put|Attach|Detach).*/
          | sort @timestamp desc
          | limit 20
        EOT
        region  = var.aws_region
        title   = "IAM Policy Changes"
        view    = "table"
      }
    },
    # Security Group Changes
    {
      type   = "log"
      x      = 0
      y      = 6
      width  = 24
      height = 6
      properties = {
        query   = <<-EOT
          fields @timestamp, eventName, userIdentity.userName, eventSource, requestParameters.groupId
          | filter eventSource = "ec2.amazonaws.com"
          | filter eventName like /SecurityGroup/
          | sort @timestamp desc
          | limit 20
        EOT
        region  = var.aws_region
        title   = "Security Group Modifications"
        view    = "table"
      }
    },
    # Root Account Usage
    {
      type   = "log"
      x      = 0
      y      = 12
      width  = 12
      height = 6
      properties = {
        query   = <<-EOT
          fields @timestamp, eventName, errorCode, sourceIPAddress
          | filter userIdentity.type = "Root"
          | sort @timestamp desc
          | limit 20
        EOT
        region  = var.aws_region
        title   = "Root Account Activity"
        view    = "table"
      }
    },
    # Failed Console Logins
    {
      type   = "log"
      x      = 12
      y      = 12
      width  = 12
      height = 6
      properties = {
        query   = <<-EOT
          fields @timestamp, eventName, userIdentity.userName, sourceIPAddress, errorMessage
          | filter eventName = "ConsoleLogin"
          | filter errorMessage like /failed/
          | sort @timestamp desc
          | limit 20
        EOT
        region  = var.aws_region
        title   = "Failed Console Logins"
        view    = "table"
      }
    },
    # API Activity by Region
    {
      type   = "log"
      x      = 0
      y      = 18
      width  = 24
      height = 6
      properties = {
        query   = <<-EOT
          fields @timestamp, awsRegion, eventSource, eventName
          | stats count(*) as eventCount by awsRegion, eventSource
          | sort eventCount desc
          | limit 20
        EOT
        region  = var.aws_region
        title   = "API Activity by Region"
        view    = "table"
      }
    }
  ]
}

# IAM Policy Change Alarm
resource "aws_cloudwatch_metric_alarm" "iam_changes" {
  alarm_name          = "iam-policy-changes"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = var.evaluation_periods
  metric_name         = "IAMPolicyEventCount"
  namespace           = "AWS/CloudTrail"
  period             = "300"
  statistic          = "Sum"
  threshold          = var.iam_change_threshold
  alarm_description  = "This metric monitors IAM policy changes"
  alarm_actions      = [var.sns_topic_arn]
}

# Root Account Usage Alarm
resource "aws_cloudwatch_metric_alarm" "root_account_usage" {
  alarm_name          = "root-account-usage"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "RootAccountUsage"
  namespace           = "AWS/CloudTrail"
  period             = "300"
  statistic          = "Sum"
  threshold          = "0"
  alarm_description  = "This metric monitors root account usage"
  alarm_actions      = [var.sns_topic_arn]
}

# Failed Console Login Alarm
resource "aws_cloudwatch_metric_alarm" "failed_console_login" {
  alarm_name          = "failed-console-logins"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = var.evaluation_periods
  metric_name         = "FailedConsoleLogins"
  namespace           = "AWS/CloudTrail"
  period             = "300"
  statistic          = "Sum"
  threshold          = var.failed_login_threshold
  alarm_description  = "This metric monitors failed console logins"
  alarm_actions      = [var.sns_topic_arn]
}

# Security Group Change Alarm
resource "aws_cloudwatch_metric_alarm" "security_group_changes" {
  alarm_name          = "security-group-changes"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = var.evaluation_periods
  metric_name         = "SecurityGroupEventCount"
  namespace           = "AWS/CloudTrail"
  period             = "300"
  statistic          = "Sum"
  threshold          = var.security_group_change_threshold
  alarm_description  = "This metric monitors security group changes"
  alarm_actions      = [var.sns_topic_arn]
}

# Unauthorized API Calls Alarm
resource "aws_cloudwatch_metric_alarm" "unauthorized_api_calls" {
  alarm_name          = "unauthorized-api-calls"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = var.evaluation_periods
  metric_name         = "UnauthorizedAttemptCount"
  namespace           = "AWS/CloudTrail"
  period             = "300"
  statistic          = "Sum"
  threshold          = var.unauthorized_api_threshold
  alarm_description  = "This metric monitors unauthorized API calls"
  alarm_actions      = [var.sns_topic_arn]
} 