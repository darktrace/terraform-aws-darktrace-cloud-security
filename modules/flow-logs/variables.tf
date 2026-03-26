variable "darktrace_cloud_security_tags" {
  type        = map(any)
  description = "Common tags to add to resources"
  default     = null
}

variable "darktrace_cloud_security_core_iam_role_arn" {
  type        = string
  description = "ARN of Darktrace/Cloud Core IAM Policy"
}

variable "sqs_queue_arns" {
  type        = list(string)
  description = "List of customer-provided SQS queue ARNs. When provided with flow_logs_bucket_name, enables 'Create Flow Logs Only' setup. When provided alone, enables 'Fully Custom with SQS' setup."
  default     = []
}

variable "flow_logs_bucket_name" {
  type        = string
  description = "Customer-provided S3 bucket name for flow logs. Must be provided together with sqs_queue_arns for 'Create Flow Logs Only' setup."
  default     = null
}

variable "kms_arns" {
  type        = list(string)
  description = "Optional list of KMS key ARNs for decryption. When provided, a KMS decrypt statement is appended to the policy."
  default     = []
}
