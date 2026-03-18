<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.8 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 5.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_cloudtrail.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudtrail) | resource |
| [aws_iam_policy.cloudtrail](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.cloudtrail](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.cloudtrail](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.security_audit](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_s3_bucket.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket_lifecycle_configuration.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_lifecycle_configuration) | resource |
| [aws_s3_bucket_notification.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_notification) | resource |
| [aws_s3_bucket_policy.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_policy) | resource |
| [aws_s3_bucket_public_access_block.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block) | resource |
| [aws_s3_bucket_server_side_encryption_configuration.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_server_side_encryption_configuration) | resource |
| [aws_s3_bucket_versioning.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_versioning) | resource |
| [aws_sqs_queue.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sqs_queue) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy_document.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_autoconfigure_cloudtrail"></a> [autoconfigure\_cloudtrail](#input\_autoconfigure\_cloudtrail) | Configure event selectors on CloudTrail for Darktrace/Cloud | `bool` | `false` | no |
| <a name="input_darktrace_cloud_security_aws_account_id"></a> [darktrace\_cloud\_security\_aws\_account\_id](#input\_darktrace\_cloud\_security\_aws\_account\_id) | Darktrace AWS Account ID | `string` | n/a | yes |
| <a name="input_darktrace_cloud_security_external_id"></a> [darktrace\_cloud\_security\_external\_id](#input\_darktrace\_cloud\_security\_external\_id) | Unique value used to identify your Darktrace/Cloud tenant | `string` | n/a | yes |
| <a name="input_darktrace_cloud_security_tags"></a> [darktrace\_cloud\_security\_tags](#input\_darktrace\_cloud\_security\_tags) | Common tags to add to resources | `map(any)` | `null` | no |
| <a name="input_existing_cloudtrail_bucket_name"></a> [existing\_cloudtrail\_bucket\_name](#input\_existing\_cloudtrail\_bucket\_name) | Existing CloudTrail Bucket Name | `string` | `null` | no |
| <a name="input_existing_cloudtrail_bucket_sqs_arn"></a> [existing\_cloudtrail\_bucket\_sqs\_arn](#input\_existing\_cloudtrail\_bucket\_sqs\_arn) | Existing CloudTrail SQS Queue ARN | `string` | `null` | no |
| <a name="input_existing_cloudtrail_name"></a> [existing\_cloudtrail\_name](#input\_existing\_cloudtrail\_name) | Existing CloudTrail Name | `string` | `null` | no |
| <a name="input_is_organization_admin_account"></a> [is\_organization\_admin\_account](#input\_is\_organization\_admin\_account) | Applies resources required for the Organization admin account when set to true | `bool` | `false` | no |
| <a name="input_kms_arns"></a> [kms\_arns](#input\_kms\_arns) | List of KMS Key ARNs that the CloudTrail role needs decrypt permissions for | `list(string)` | `[]` | no |
| <a name="input_setup_cloudtrail"></a> [setup\_cloudtrail](#input\_setup\_cloudtrail) | Setup permissions and optional resources for Darktrace /CLOUD AWS Audit Logs. Only should be true for either a single management account or a single logging account. One account per organisation. | `bool` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_darktrace_cloud_security_core_iam_role_arn"></a> [darktrace\_cloud\_security\_core\_iam\_role\_arn](#output\_darktrace\_cloud\_security\_core\_iam\_role\_arn) | ARN of Darktrace/Cloud Core IAM Policy |
<!-- END_TF_DOCS -->
