# AWS Cloudwatch Logs to Firehose Terraform

This section creates a AWS Lambda function that will convert Cloudwatch logs subscription to firehose to convert it from Json to emits one line per log message for S3 bucket storage and ease of ingestion by Elastic.
