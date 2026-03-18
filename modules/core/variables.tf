variable "darktrace_cloud_security_aws_account_id" {
  type        = string
  description = "Darktrace AWS Account ID"
}

variable "darktrace_cloud_security_tags" {
  type        = map(any)
  description = "Common tags to add to resources"
  default     = null
}

variable "is_organization_admin_account" {
  type        = bool
  description = "Applies resources required for the Organization admin account when set to true"
  default     = false
}

variable "setup_cloudtrail" {
  type        = bool
  description = "Setup permissions and optional resources for Darktrace /CLOUD AWS Audit Logs. Only should be true for either a single management account or a single logging account. One account per organisation."
}

variable "autoconfigure_cloudtrail" {
  type        = bool
  description = "Configure event selectors on CloudTrail for Darktrace/Cloud"
  default     = false
}

variable "darktrace_cloud_security_external_id" {
  type        = string
  description = "Unique value used to identify your Darktrace/Cloud tenant"
  sensitive   = true
}

variable "existing_cloudtrail_name" {
  type        = string
  description = "Existing CloudTrail Name"
  default     = null
}

variable "existing_cloudtrail_bucket_name" {
  type        = string
  description = "Existing CloudTrail Bucket Name"
  default     = null
}

variable "existing_cloudtrail_bucket_sqs_arn" {
  type        = string
  description = "Existing CloudTrail SQS Queue ARN"
  default     = null
}

variable "kms_arns" {
  type        = list(string)
  description = "List of KMS Key ARNs that the CloudTrail role needs decrypt permissions for"
  default     = []
}
