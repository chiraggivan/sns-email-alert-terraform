provider "aws" {
  region = "eu-north-1"  # You can change this if needed
}

resource "aws_sns_topic" "logger_alerts" {
  name = "logger-alert-topic"
}

resource "aws_sns_topic_subscription" "email_alert" {
  topic_arn = aws_sns_topic.logger_alerts.arn
  protocol  = "email"
  endpoint  = "chirag.damania@gmail.com"
}

resource "aws_cloudwatch_log_metric_filter" "logger_error_filter" {
  name           = "logger-error-filter"
  log_group_name = "/aws/lambda/RDStoS3function"
  pattern        = "ERROR"

  metric_transformation {
    name      = "LoggerErrorCount"
    namespace = "RDSToS3App"
    value     = "1"
  }
}

resource "aws_cloudwatch_metric_alarm" "logger_error_alarm" {
  alarm_name          = "LoggerErrorAlarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "LoggerErrorCount"
  namespace           = "RDSToS3App"
  period              = 60
  statistic           = "Sum"
  threshold           = 1

  alarm_description   = "Alarm when logger.error is detected in Lambda logs"
  treat_missing_data  = "notBreaching"

  alarm_actions       = [aws_sns_topic.logger_alerts.arn]
}
