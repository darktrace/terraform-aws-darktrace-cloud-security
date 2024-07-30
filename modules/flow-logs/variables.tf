variable "darktrace_cloud_security_tags" {
  type        = map(any)
  description = "Common tags to add to resources"
  default     = null
}

variable "darktrace_cloud_security_core_iam_role_arn" {
  type        = string
  description = "ARN of Darktrace/Cloud Core IAM Policy"
}

variable "existing_flow_log_bucket_name" {
  type        = list(string)
  description = "Existing Flow Log Bucket Name"
  default     = []
}
