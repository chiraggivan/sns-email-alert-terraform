# Lambda RDS Error Monitoring with CloudWatch + SNS Alerts

This project sets up a serverless monitoring pipeline using AWS Lambda, CloudWatch, and SNS to automatically detect and notify about errors in Lambda logs — specifically connection errors to an RDS MySQL instance.

## 🚀 Features

- Detects `[ERROR]` entries in Lambda logs
- Triggers CloudWatch alarms when errors occur
- Sends email notifications via Amazon SNS
- Infrastructure is fully defined in Terraform

---

## 🧱 Architecture

