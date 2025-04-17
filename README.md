# Error Monitoring with CloudWatch + SNS Alerts

This project sets up a serverless error monitoring pipeline using AWS Lambda, CloudWatch, and SNS to automatically detect and notify users about errors in Lambda logs, all managed through Terraform. The aim is to capture errors (such as database connection failures or S3 upload issues) from the food delivery data pipeline, filter them based on a defined pattern, and trigger an alarm that sends an SNS email notification — all without the need to interact with the AWS UI.

The error logging system leverages a CloudWatch subscription filter to capture error logs from the pipeline’s Lambda function (mysql-to-s3). These logs are processed according to predefined patterns using CloudWatch Metric Filters, and any errors encountered are sent via email through an AWS SNS topic to a registered email address. The entire process is orchestrated using Terraform.
## Features

- Detects `[ERROR]` entries in Lambda logs
- Triggers CloudWatch alarms when errors occur
- Sends email notifications via Amazon SNS
- Infrastructure is fully defined in Terraform

---

## Architecture

Lambda ➡️ Logs ➡️ CloudWatch Metric Filter ➡️ Alarm ➡️ SNS ➡️ Email

## Technologies Used
-   AWS Lambda (Python)
-   AWS RDS (MySQL)
-   AWS CloudWatch
-   AWS SNS
-   Terraform

## Prerequisites: 
- IAM user/role with permissions: `Lambda`, `RDS`, `CloudWatch`, `SNS`, `SSM`
- Terraform installed

## Explanation of main.tf file(Terraform file)

```
provider "aws" {
  region = "eu-north-1"
}
```
- This sets the AWS region where all your resources will be created (eu-north-1, aka Stockholm).
- Required to tell Terraform where to deploy things.

```
resource "aws_sns_topic" "logger_alerts" {
  name = "logger-alert-topic"
}
```
- This creates an SNS topic called logger-alert-topic.
- SNS is used to send notifications — here, email alerts when errors occur.

```
resource "aws_sns_topic_subscription" "email_alert" {
  topic_arn = aws_sns_topic.logger_alerts.arn
  protocol  = "email"
  endpoint  = "chirag.damania@gmail.com"
}
```
- Subscribes your email address to the SNS topic.
- When an alert is triggered, an email will be sent to you.
- You'll get a confirmation email first — you have to confirm the subscription manually once.

```
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
```
- This monitors a specific log group (in this case, logs from the Lambda function RDStoS3function).
- It looks for any log entry that contains the word ERROR.
- When it finds a match, it creates a metric named LoggerErrorCount in the namespace RDSToS3App.
- Every time an error is logged, the metric increases by 1.

So it's like:

“Hey CloudWatch, turn these logs into countable metrics I can set alarms on.”
aws_cloudwatch_metric_alarm — Set Alarm on Error Metric

```
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
```

This creates an alarm that:

- Watches the LoggerErrorCount metric
- Looks for values ≥ 1 (i.e., an error was logged)
- Over a 60-second window
- If triggered, the alarm:
- Sends a notification via the SNS topic
- treat_missing_data = "notBreaching" means:
- If there's no data (e.g., no logs yet), it won’t trigger the alarm unnecessarily.