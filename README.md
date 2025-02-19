# tofu-aws-scalr-managed-s3-backend
Opentofu module for an AWS S3 remote backend with DynamoDB locking, managed via Scalr using OpenID Connect (OIDC). It creates an S3 bucket for storing Opentofu state, a DynamoDB table for state locking, and an IAM role to allow Scalr to assume permissions via OIDC.

<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.87.0 |
| <a name="provider_random"></a> [random](#provider\_random) | 3.6.3 |
| <a name="provider_tls"></a> [tls](#provider\_tls) | 4.0.6 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_dynamodb_table.tofu_locks](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/dynamodb_table) | resource |
| [aws_iam_openid_connect_provider.scalr_te](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_openid_connect_provider) | resource |
| [aws_iam_role.tofu](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_s3_bucket.tofu_state](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [random_string.names_suffix](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |
| [aws_iam_policy_document.assume_from_scalr](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.tofu_permissions](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [tls_certificate.scalr_te](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/data-sources/certificate) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_bucket_name"></a> [bucket\_name](#input\_bucket\_name) | Custom S3 bucket name. If not provided, 'tf-state' name with random suffix will be used. | `string` | `null` | no |
| <a name="input_dynamodb_table_name"></a> [dynamodb\_table\_name](#input\_dynamodb\_table\_name) | Custom DynamoDB table name. If not provided, 'tf-locks' name with random suffix will be used. | `string` | `null` | no |
| <a name="input_enable_dynamodb_pitr"></a> [enable\_dynamodb\_pitr](#input\_enable\_dynamodb\_pitr) | Enable Point-in-Time Recovery for DynamoDB table | `bool` | `false` | no |
| <a name="input_enable_s3_encryption"></a> [enable\_s3\_encryption](#input\_enable\_s3\_encryption) | Enable server-side encryption for S3 bucket | `bool` | `true` | no |
| <a name="input_oidc_aud_value"></a> [oidc\_aud\_value](#input\_oidc\_aud\_value) | n/a | `string` | `"aws.scalr-run-workload"` | no |
| <a name="input_scalr_account_name"></a> [scalr\_account\_name](#input\_scalr\_account\_name) | Scalr account name | `string` | n/a | yes |
| <a name="input_scalr_environment_name"></a> [scalr\_environment\_name](#input\_scalr\_environment\_name) | Scalr environment name. Workloads running in this environment will have access to the state bucket and DynamoDB lock table. | `string` | n/a | yes |
| <a name="input_scalr_hostname"></a> [scalr\_hostname](#input\_scalr\_hostname) | Scalr hostname | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_bucket_name"></a> [bucket\_name](#output\_bucket\_name) | Tofu state S3 bucket name |
| <a name="output_scalr_role_arn"></a> [scalr\_role\_arn](#output\_scalr\_role\_arn) | ARN of the IAM Role for Scalr |
| <a name="output_table_name"></a> [table\_name](#output\_table\_name) | Tofu state lock DynamoDB table name |
<!-- END_TF_DOCS -->