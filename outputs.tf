output "scalr_role_arn" {
  description = "ARN of the IAM Role for Scalr"
  value       = aws_iam_role.tofu.arn
}

output "bucket_name" {
  description = "Tofu state S3 bucket name"
  value       = aws_s3_bucket.tofu_state.bucket
}

output "table_name" {
  description = "Tofu state lock DynamoDB table name"
  value       = aws_dynamodb_table.tofu_locks.name
}
