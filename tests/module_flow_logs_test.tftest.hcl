mock_provider "aws" {}

# Test Run 1: Type 1 backward compatibility (Darktrace Managed defaults)
# Validates: Requirements 8.1, 8.2, 4.1, 4.2, 4.3, 4.4, 4.5, 4.6
run "module_flow_logs_defaults" {
  command = plan

  providers = {
    aws = aws
  }

  module {
    source = "./modules/flow-logs"
  }

  variables {
    darktrace_cloud_security_core_iam_role_arn = "arn:aws:iam::123456789012:role/test-role"
  }

  assert {
    condition     = aws_iam_role.default.name == "DarktraceFlowLogsRole"
    error_message = "IAM role name should be DarktraceFlowLogsRole"
  }

  assert {
    condition     = aws_iam_policy.default.name == "DarktraceFlowLogsPolicy"
    error_message = "IAM policy name should be DarktraceFlowLogsPolicy"
  }

  assert {
    condition     = can(regex("sqs:CreateQueue", aws_iam_policy.default.policy))
    error_message = "Type 1 policy should contain sqs:CreateQueue (SQS management)"
  }

  assert {
    condition     = can(regex("s3:CreateBucket", aws_iam_policy.default.policy))
    error_message = "Type 1 policy should contain s3:CreateBucket (broad permissions)"
  }

  assert {
    condition     = can(regex("s3:DeleteBucket", aws_iam_policy.default.policy))
    error_message = "Type 1 policy should contain s3:DeleteBucket (S3 management)"
  }

  assert {
    condition     = can(regex("ec2:DeleteFlowLogs", aws_iam_policy.default.policy))
    error_message = "Type 1 policy should contain ec2:DeleteFlowLogs (tag-conditioned delete)"
  }

  assert {
    condition     = can(regex("iam:CreateServiceLinkedRole", aws_iam_policy.default.policy))
    error_message = "Type 1 policy should contain iam:CreateServiceLinkedRole (IAM SLR)"
  }

  assert {
    condition     = !can(regex("kms:Decrypt", aws_iam_policy.default.policy))
    error_message = "Type 1 policy should not contain kms:Decrypt (no KMS)"
  }
}

# Test Run 2: Type 2 — Create Flow Logs Only
# Validates: Requirements 5.1, 5.2, 5.3, 5.4, 5.5, 5.6, 10.2
run "module_flow_logs_create_flow_logs" {
  command = plan

  providers = {
    aws = aws
  }

  module {
    source = "./modules/flow-logs"
  }

  variables {
    darktrace_cloud_security_core_iam_role_arn = "arn:aws:iam::123456789012:role/test-role"
    sqs_queue_arns                             = ["arn:aws:sqs:eu-west-1:123456789012:my-flowlogs-queue"]
    flow_logs_bucket_name                      = "my-flowlogs-bucket"
  }

  assert {
    condition     = aws_iam_role.default.name == "DarktraceFlowLogsRole"
    error_message = "IAM role name should be DarktraceFlowLogsRole"
  }

  assert {
    condition     = aws_iam_policy.default.name == "DarktraceFlowLogsPolicy"
    error_message = "IAM policy name should be DarktraceFlowLogsPolicy"
  }

  assert {
    condition     = can(regex("sqs:ReceiveMessage", aws_iam_policy.default.policy))
    error_message = "Type 2 policy should contain sqs:ReceiveMessage (SQS consume)"
  }

  assert {
    condition     = can(regex("s3:GetObject", aws_iam_policy.default.policy))
    error_message = "Type 2 policy should contain s3:GetObject (S3 object read)"
  }

  assert {
    condition     = can(regex("s3:PutBucketNotification", aws_iam_policy.default.policy))
    error_message = "Type 2 policy should contain s3:PutBucketNotification (bucket-level)"
  }

  assert {
    condition     = can(regex("my-flowlogs-bucket", aws_iam_policy.default.policy))
    error_message = "Type 2 policy should contain customer bucket name in resource"
  }

  assert {
    condition     = can(regex("my-flowlogs-queue", aws_iam_policy.default.policy))
    error_message = "Type 2 policy should contain customer SQS ARN in resource"
  }

  assert {
    condition     = can(regex("ec2:CreateFlowLogs", aws_iam_policy.default.policy))
    error_message = "Type 2 policy should contain ec2:CreateFlowLogs (broad permissions)"
  }

  assert {
    condition     = can(regex("ec2:DeleteFlowLogs", aws_iam_policy.default.policy))
    error_message = "Type 2 policy should contain ec2:DeleteFlowLogs (tag-conditioned delete)"
  }

  assert {
    condition     = can(regex("iam:CreateServiceLinkedRole", aws_iam_policy.default.policy))
    error_message = "Type 2 policy should contain iam:CreateServiceLinkedRole (IAM SLR)"
  }

  assert {
    condition     = !can(regex("sqs:CreateQueue", aws_iam_policy.default.policy))
    error_message = "Type 2 policy should not contain sqs:CreateQueue (Type 1 only)"
  }

  assert {
    condition     = !can(regex("s3:CreateBucket", aws_iam_policy.default.policy))
    error_message = "Type 2 policy should not contain s3:CreateBucket (Type 1 only)"
  }

  assert {
    condition     = !can(regex("kms:Decrypt", aws_iam_policy.default.policy))
    error_message = "Type 2 policy should not contain kms:Decrypt (no KMS)"
  }
}

# Test Run 3: Type 3 — Fully Custom with SQS
# Validates: Requirements 6.1, 6.2, 6.3, 6.4, 10.3
run "module_flow_logs_custom_sqs" {
  command = plan

  providers = {
    aws = aws
  }

  module {
    source = "./modules/flow-logs"
  }

  variables {
    darktrace_cloud_security_core_iam_role_arn = "arn:aws:iam::123456789012:role/test-role"
    sqs_queue_arns                             = ["arn:aws:sqs:eu-west-1:123456789012:my-flowlogs-queue"]
  }

  assert {
    condition     = aws_iam_role.default.name == "DarktraceFlowLogsRole"
    error_message = "IAM role name should be DarktraceFlowLogsRole"
  }

  assert {
    condition     = aws_iam_policy.default.name == "DarktraceFlowLogsPolicy"
    error_message = "IAM policy name should be DarktraceFlowLogsPolicy"
  }

  assert {
    condition     = can(regex("sqs:ReceiveMessage", aws_iam_policy.default.policy))
    error_message = "Type 3 policy should contain sqs:ReceiveMessage (SQS consume)"
  }

  assert {
    condition     = can(regex("s3:GetObject", aws_iam_policy.default.policy))
    error_message = "Type 3 policy should contain s3:GetObject (S3 object read)"
  }

  assert {
    condition     = can(regex("my-flowlogs-queue", aws_iam_policy.default.policy))
    error_message = "Type 3 policy should contain customer SQS ARN in resource"
  }

  assert {
    condition     = !can(regex("sqs:CreateQueue", aws_iam_policy.default.policy))
    error_message = "Type 3 policy should not contain sqs:CreateQueue (Type 1 only)"
  }

  assert {
    condition     = !can(regex("s3:CreateBucket", aws_iam_policy.default.policy))
    error_message = "Type 3 policy should not contain s3:CreateBucket (Type 1 only)"
  }

  assert {
    condition     = !can(regex("ec2:CreateFlowLogs", aws_iam_policy.default.policy))
    error_message = "Type 3 policy should not contain ec2:CreateFlowLogs (Type 1 and 2 only)"
  }

  assert {
    condition     = !can(regex("ec2:DeleteFlowLogs", aws_iam_policy.default.policy))
    error_message = "Type 3 policy should not contain ec2:DeleteFlowLogs (Type 1 and 2 only)"
  }

  assert {
    condition     = !can(regex("iam:CreateServiceLinkedRole", aws_iam_policy.default.policy))
    error_message = "Type 3 policy should not contain iam:CreateServiceLinkedRole (Type 1 and 2 only)"
  }

  assert {
    condition     = !can(regex("s3:PutBucketNotification", aws_iam_policy.default.policy))
    error_message = "Type 3 policy should not contain s3:PutBucketNotification (Type 2 only)"
  }

  assert {
    condition     = !can(regex("kms:Decrypt", aws_iam_policy.default.policy))
    error_message = "Type 3 policy should not contain kms:Decrypt (no KMS)"
  }
}

# Test Run 4: KMS support (Type 1 + KMS)
# Validates: Requirements 7.1, 7.2, 7.3
run "module_flow_logs_with_kms" {
  command = plan

  providers = {
    aws = aws
  }

  module {
    source = "./modules/flow-logs"
  }

  variables {
    darktrace_cloud_security_core_iam_role_arn = "arn:aws:iam::123456789012:role/test-role"
    kms_arns                                   = ["arn:aws:kms:eu-west-1:123456789012:key/test-key-1"]
  }

  assert {
    condition     = can(regex("kms:Decrypt", aws_iam_policy.default.policy))
    error_message = "Policy should contain kms:Decrypt when kms_arns is provided"
  }

  assert {
    condition     = can(regex("arn:aws:kms:eu-west-1:123456789012:key/test-key-1", aws_iam_policy.default.policy))
    error_message = "Policy should contain the specific KMS ARN"
  }

  assert {
    condition     = can(regex("sqs:CreateQueue", aws_iam_policy.default.policy))
    error_message = "Policy should still contain sqs:CreateQueue (Type 1 since no SQS/bucket vars)"
  }
}

# Test Run 5: Input validation — bucket without SQS
# Validates: Requirements 3.1, 3.2
run "module_flow_logs_invalid_bucket_only" {
  command = plan

  providers = {
    aws = aws
  }

  module {
    source = "./modules/flow-logs"
  }

  variables {
    darktrace_cloud_security_core_iam_role_arn = "arn:aws:iam::123456789012:role/test-role"
    flow_logs_bucket_name                      = "invalid-bucket"
  }

  expect_failures = [aws_iam_role.default]
}
