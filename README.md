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

