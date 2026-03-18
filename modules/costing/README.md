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
| <a name="provider_aws.us_east_1"></a> [aws.us\_east\_1](#provider\_aws.us\_east\_1) | >= 5.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_cur_report_definition.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cur_report_definition) | resource |
| [aws_iam_policy.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_s3_bucket.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket_lifecycle_configuration.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_lifecycle_configuration) | resource |
| [aws_s3_bucket_policy.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_policy) | resource |
| [aws_s3_bucket_public_access_block.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block) | resource |
| [aws_s3_bucket_versioning.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_versioning) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_darktrace_cloud_security_core_iam_role_arn"></a> [darktrace\_cloud\_security\_core\_iam\_role\_arn](#input\_darktrace\_cloud\_security\_core\_iam\_role\_arn) | ARN of Darktrace/Cloud Core IAM Policy | `string` | n/a | yes |
| <a name="input_darktrace_cloud_security_tags"></a> [darktrace\_cloud\_security\_tags](#input\_darktrace\_cloud\_security\_tags) | Common tags to add to resources | `map(any)` | `null` | no |
| <a name="input_existing_cur_bucket_name"></a> [existing\_cur\_bucket\_name](#input\_existing\_cur\_bucket\_name) | Existing CUR Bucket Name | `string` | `null` | no |
| <a name="input_existing_cur_bucket_prefix"></a> [existing\_cur\_bucket\_prefix](#input\_existing\_cur\_bucket\_prefix) | Existing CUR Bucket Prefix | `string` | `null` | no |
| <a name="input_existing_cur_report_name"></a> [existing\_cur\_report\_name](#input\_existing\_cur\_report\_name) | Existing CUR Report Name | `string` | `null` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
