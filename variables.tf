variable "bucket_name" {
  description = "Custom S3 bucket name. If not provided, 'tf-state' name with random suffix will be used."
  type        = string
  default     = null
}

variable "dynamodb_table_name" {
  description = "Custom DynamoDB table name. If not provided, 'tf-locks' name with random suffix will be used."
  type        = string
  default     = null
}


variable "enable_s3_encryption" {
  description = "Enable server-side encryption for S3 bucket"
  type        = bool
  default     = true
}

variable "enable_dynamodb_pitr" {
  description = "Enable Point-in-Time Recovery for DynamoDB table"
  type        = bool
  default     = false
}

variable "scalr_hostname" {
  type        = string
  description = "Scalr hostname"
}

variable "oidc_aud_value" {
  type    = string
  default = "aws.scalr-run-workload"
}

variable "scalr_account_name" {
  type        = string
  description = "Scalr account name"
}
