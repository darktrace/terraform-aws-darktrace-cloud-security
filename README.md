# terraform-aws-darktrace-cloud-security

**Please note: this module is not intended to be directly consumed. For usage instructions please consult your Darktrace/Cloud setup guide.**

## Introduction

This repository offers terraform modules for deploying various resources required by Darktrace/Cloud to enable DETECT and RESPOND features for your Amazon Web Services (AWS) Cloud environment:

- **Core**: allows Darktrace/Cloud to monitor your AWS Cloud environment
- **Costing**: allows Darktrace/Cloud to perform cost analysis of various resources within your AWS Cloud environment
- **Flow Logs**: allows Darktrace/Cloud to analyse network traffic within your AWS Cloud environment
- **RESPOND**: allows Darktrace/Cloud to perform RESPOND actions against misconfigured resources within your AWS Cloud environment

## Usage

### Before you start

You must be an active Darktrace/Cloud customer, and have relevant permissions on your AWS account(s) to apply the resources this terraform module will create

### Retrieving values

Follow the Account Setup guide on your Darktrace/Cloud UI. Upon completion, you will be provided with the necessary values required to use the relevant terraform module(s). Please do not modify the values provided to you by the Account Setup guide.

## Example

```hcl
variable "darktrace_cloud_security_external_id" {
  type        = string
  description = "Unique value used to identify your Darktrace/Cloud tenant"
}

module "darktrace_cloud_security_core" {
  source  = "darktrace/darktrace-cloud-security/aws//modules/core"
  version = "1.0.0"

  darktrace_cloud_security_aws_account_id = ""
  darktrace_cloud_security_external_id    = var.darktrace_cloud_security_external_id
}

module "darktrace_cloud_security_flow_logs" {
  source                                     = "darktrace/darktrace-cloud-security/aws//modules/flow-logs"
  version                                    = "1.0.0"
  darktrace_cloud_security_core_iam_role_arn = module.darktrace_cloud_security_core.darktrace_cloud_security_core_iam_role_arn
}

module "darktrace_cloud_security_costing" {
  source                                     = "darktrace/darktrace-cloud-security/aws//modules/costing"
  version                                    = "1.0.0"
  darktrace_cloud_security_core_iam_role_arn = module.darktrace_cloud_security_core.darktrace_cloud_security_core_iam_role_arn
}

module "darktrace_cloud_security_respond" {
  source                                     = "darktrace/darktrace-cloud-security/aws//modules/respond"
  version                                    = "1.0.0"
  darktrace_cloud_security_core_iam_role_arn = module.darktrace_cloud_security_core.darktrace_cloud_security_core_iam_role_arn
}
```

## Darktrace v7.0 - upgrading to module version 2.0

Darktrace v7.0 requires Terraform module version 2.0.

Version 2.0+ introduces a new default to configure CloudTrail setup. To retain previous behaviour please ensure the core module has the `setup_cloudtrail` variable set to `false`.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.8 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.0 |

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_darktrace_cloud_security_core"></a> [darktrace\_cloud\_security\_core](#module\_darktrace\_cloud\_security\_core) | darktrace/darktrace-cloud-security/aws//modules/core | 1.0.0 |
| <a name="module_darktrace_cloud_security_costing"></a> [darktrace\_cloud\_security\_costing](#module\_darktrace\_cloud\_security\_costing) | darktrace/darktrace-cloud-security/aws//modules/costing | 1.0.0 |
| <a name="module_darktrace_cloud_security_flow_logs"></a> [darktrace\_cloud\_security\_flow\_logs](#module\_darktrace\_cloud\_security\_flow\_logs) | darktrace/darktrace-cloud-security/aws//modules/flow-logs | 1.0.0 |
| <a name="module_darktrace_cloud_security_respond"></a> [darktrace\_cloud\_security\_respond](#module\_darktrace\_cloud\_security\_respond) | darktrace/darktrace-cloud-security/aws//modules/respond | 1.0.0 |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_darktrace_cloud_security_external_id"></a> [darktrace\_cloud\_security\_external\_id](#input\_darktrace\_cloud\_security\_external\_id) | Unique value used to identify your Darktrace/Cloud tenant | `string` | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->