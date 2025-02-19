resource "random_string" "names_suffix" {
  count   = var.bucket_name == null || var.dynamodb_table_name == null ? 1 : 0
  length  = 6
  special = false
}

locals {
  bucket_name         = var.bucket_name != null ? var.bucket_name : "tf-state-${random_string.names_suffix[0].id}"
  dynamodb_table_name = var.dynamodb_table_name != null ? var.dynamodb_table_name : "tf-locks-${random_string.names_suffix[0].id}"
}

resource "aws_s3_bucket" "tofu_state" {
  bucket = local.bucket_name
  acl    = "private"

  versioning {
    enabled = true
  }

  dynamic "server_side_encryption_configuration" {
    for_each = var.enable_s3_encryption ? [1] : []
    content {
      rule {
        apply_server_side_encryption_by_default {
          sse_algorithm = "AES256"
        }
      }
    }
  }

  tags = {
    Name        = "TofuStateBucket"
    Environment = "dev"
  }
}

resource "aws_dynamodb_table" "tofu_locks" {
  name         = local.dynamodb_table_name
  billing_mode = "PAY_PER_REQUEST"

  attribute {
    name = "LockID"
    type = "S"
  }

  hash_key = "LockID"

  dynamic "point_in_time_recovery" {
    for_each = var.enable_dynamodb_pitr ? [1] : []
    content {
      enabled = true
    }
  }

  ttl {
    attribute_name = "TTL"
    enabled        = true
  }

  tags = {
    Name        = "TofuLockTable"
    Environment = "dev"
  }
}

data "tls_certificate" "scalr_te" {
  url = "https://${var.scalr_hostname}"
}

resource "aws_iam_openid_connect_provider" "scalr_te" {
  url             = data.tls_certificate.scalr_te.url
  client_id_list  = [var.oidc_aud_value]
  thumbprint_list = [data.tls_certificate.scalr_te.certificates[0].sha1_fingerprint]
}

data "aws_iam_policy_document" "assume_from_scalr" {
  statement {
    sid     = "allow-scalr-${var.scalr_account_name}-${var.scalr_environment_name}"
    actions = ["sts:AssumeRoleWithWebIdentity"]
    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.scalr_te.arn]
    }
    condition {
      test     = "StringLike"
      variable = "${var.scalr_hostname}:sub"
      values = [
        format(
          "account:%s:environment:%s:workspace:*",
          var.scalr_account_name,
          var.scalr_environment_name,
        )
      ]
    }
  }
}

resource "aws_iam_role" "tofu_backend_access" {
  name               = "scalr-tofu-backend-access"
  assume_role_policy = data.aws_iam_policy_document.assume_from_scalr.json

  tags = {
    Name        = "SCALR Tofu"
    Environment = "Dev"
    Application = "ScalrTE"
  }
}

data "aws_iam_policy_document" "tofu_backend_permissions" {
  statement {
    sid    = "S3Access"
    effect = "Allow"
    actions = [
      "s3:ListBucket",
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject",
    ]
    resources = [
      aws_s3_bucket.tofu_state.arn,
      "${aws_s3_bucket.tofu_state.arn}/*"
    ]
  }

  statement {
    sid    = "DynamoDBAccess"
    effect = "Allow"
    actions = [
      "dynamodb:PutItem",
      "dynamodb:GetItem",
      "dynamodb:DeleteItem",
      "dynamodb:Scan",
      "dynamodb:Query",
      "dynamodb:UpdateItem"
    ]
    resources = [aws_dynamodb_table.tofu_locks.arn]
  }
}

resource "aws_iam_role_policy" "tofu_backend_permissions" {
  name   = "TofuBackendPermissions"
  role   = aws_iam_role.tofu_backend_access.id
  policy = data.aws_iam_policy_document.tofu_backend_permissions.json
}
