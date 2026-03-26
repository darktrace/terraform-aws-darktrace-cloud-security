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
| [aws_iam_policy.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_darktrace_cloud_security_core_iam_role_arn"></a> [darktrace\_cloud\_security\_core\_iam\_role\_arn](#input\_darktrace\_cloud\_security\_core\_iam\_role\_arn) | ARN of Darktrace/Cloud Core IAM Policy | `string` | n/a | yes |
| <a name="input_darktrace_cloud_security_tags"></a> [darktrace\_cloud\_security\_tags](#input\_darktrace\_cloud\_security\_tags) | Common tags to add to resources | `map(any)` | `null` | no |
| <a name="input_flow_logs_bucket_name"></a> [flow\_logs\_bucket\_name](#input\_flow\_logs\_bucket\_name) | Customer-provided S3 bucket name for flow logs. Must be provided together with sqs\_queue\_arns for 'Create Flow Logs Only' setup. | `string` | `null` | no |
| <a name="input_kms_arns"></a> [kms\_arns](#input\_kms\_arns) | Optional list of KMS key ARNs for decryption. When provided, a KMS decrypt statement is appended to the policy. | `list(string)` | `[]` | no |
| <a name="input_sqs_queue_arns"></a> [sqs\_queue\_arns](#input\_sqs\_queue\_arns) | List of customer-provided SQS queue ARNs. When provided with flow\_logs\_bucket\_name, enables 'Create Flow Logs Only' setup. When provided alone, enables 'Fully Custom with SQS' setup. | `list(string)` | `[]` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
