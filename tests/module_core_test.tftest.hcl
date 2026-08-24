mock_provider "aws" {}

override_data {
  target = data.aws_iam_policy_document.default[0]
  values = {
    json = "{}"
  }
}

run "module_core_dt_managed" {
  command = plan

  module {
    source = "./modules/core"
  }

  variables {
    darktrace_cloud_security_aws_account_id = "123456789012"
    darktrace_cloud_security_external_id    = "test-external-id"
    setup_cloudtrail                        = true
    autoconfigure_cloudtrail                = true
  }

  assert {
    condition     = aws_iam_role.default.name == "DarktraceRole"
    error_message = "IAM role name should be DarktraceRole"
  }

  assert {
    condition     = aws_cloudtrail.default[0].name == "DarktraceTrail"
    error_message = "CloudTrail name should be DarktraceTrail"
  }

  assert {
    condition     = length(aws_cloudtrail.default) > 0
    error_message = "CloudTrail should be created"
  }

  assert {
    condition     = length(aws_s3_bucket.default) > 0
    error_message = "S3 bucket should be created"
  }

  assert {
    condition     = length(aws_sqs_queue.default) > 0
    error_message = "SQS queue should be created"
  }
}

run "module_core_existing_infra_no_sqs" {
  command = plan

  module {
    source = "./modules/core"
  }

  variables {
    darktrace_cloud_security_aws_account_id = "123456789012"
    darktrace_cloud_security_external_id    = "test-external-id"
    existing_cloudtrail_name                = "existing-trail"
    existing_cloudtrail_bucket_name         = "existing-bucket"
    setup_cloudtrail                        = true
  }

  assert {
    condition     = length(aws_cloudtrail.default) == 0
    error_message = "CloudTrail should not be created when using existing trail"
  }

  assert {
    condition     = length(aws_s3_bucket.default) == 0
    error_message = "S3 bucket should not be created when using existing bucket"
  }

  assert {
    condition     = length(aws_sqs_queue.default) == 0
    error_message = "SQS queue should be created"
  }

  assert {
    condition     = !can(regex("sqs:ReceiveMessage", aws_iam_policy.cloudtrail[0].policy))
    error_message = "Existing Infrastructure IAM Policy does contains SQS Permissions when SQS is not provided"
  }

  assert {
    condition     = can(regex("s3:ListBucket", aws_iam_policy.cloudtrail[0].policy))
    error_message = "Existing Infrastructure No-SQS does not have ListBucket permissions"
  }
}

run "module_core_existing_infra_sqs" {
  command = plan

  module {
    source = "./modules/core"
  }

  variables {
    darktrace_cloud_security_aws_account_id = "123456789012"
    darktrace_cloud_security_external_id    = "test-external-id"
    existing_cloudtrail_name                = "existing-trail"
    existing_cloudtrail_bucket_name         = "existing-bucket"
    existing_cloudtrail_bucket_sqs_arn      = "my-sqs"
    setup_cloudtrail                        = true
  }

  assert {
    condition     = length(aws_cloudtrail.default) == 0
    error_message = "CloudTrail should not be created when using existing trail"
  }

  assert {
    condition     = length(aws_s3_bucket.default) == 0
    error_message = "S3 bucket should not be created when using existing bucket"
  }

  assert {
    condition     = length(aws_sqs_queue.default) == 0
    error_message = "SQS queue should be created"
  }
  assert {
    condition     = can(regex("sqs:ReceiveMessage", aws_iam_policy.cloudtrail[0].policy))
    error_message = "Existing Infrastructure IAM Policy does not contain SQS Permissions when SQS is provided"
  }
}

run "module_core_no_kms" {
  command = plan

  module {
    source = "./modules/core"
  }

  variables {
    darktrace_cloud_security_aws_account_id = "123456789012"
    darktrace_cloud_security_external_id    = "test-external-id"
    existing_cloudtrail_name                = "existing-trail"
    existing_cloudtrail_bucket_name         = "existing-bucket"
    setup_cloudtrail                        = true
  }

  assert {
    condition     = !can(regex("kms:Decrypt", aws_iam_policy.cloudtrail[0].policy))
    error_message = "CloudTrail policy should not contain kms:Decrypt when kms_arns is not provided"
  }
}

run "module_core_single_kms_arn" {
  command = plan

  module {
    source = "./modules/core"
  }

  variables {
    darktrace_cloud_security_aws_account_id = "123456789012"
    darktrace_cloud_security_external_id    = "test-external-id"
    existing_cloudtrail_name                = "existing-trail"
    existing_cloudtrail_bucket_name         = "existing-bucket"
    setup_cloudtrail                        = true
    kms_arns                                = ["arn:aws:kms:us-east-1:123456789012:key/test-key-1"]
  }

  assert {
    condition     = can(regex("kms:Decrypt", aws_iam_policy.cloudtrail[0].policy))
    error_message = "CloudTrail policy should contain kms:Decrypt when kms_arns is provided"
  }

  assert {
    condition     = can(regex("Allow", aws_iam_policy.cloudtrail[0].policy))
    error_message = "CloudTrail policy KMS statement should have Effect Allow"
  }

  assert {
    condition     = can(regex("arn:aws:kms:us-east-1:123456789012:key/test-key-1", aws_iam_policy.cloudtrail[0].policy))
    error_message = "CloudTrail policy should contain the specific KMS ARN"
  }
}

run "module_core_multiple_kms_arns" {
  command = plan

  module {
    source = "./modules/core"
  }

  variables {
    darktrace_cloud_security_aws_account_id = "123456789012"
    darktrace_cloud_security_external_id    = "test-external-id"
    existing_cloudtrail_name                = "existing-trail"
    existing_cloudtrail_bucket_name         = "existing-bucket"
    setup_cloudtrail                        = true
    kms_arns                                = ["arn:aws:kms:us-east-1:123456789012:key/test-key-1", "arn:aws:kms:eu-west-1:123456789012:key/test-key-2"]
  }

  # Property 3: Resource scoping (multiple ARNs)
  # Validates: Requirements 2.1, 3.1, 3.3
  assert {
    condition     = can(regex("kms:Decrypt", aws_iam_policy.cloudtrail[0].policy))
    error_message = "CloudTrail policy should contain kms:Decrypt when kms_arns is provided"
  }

  assert {
    condition     = can(regex("arn:aws:kms:us-east-1:123456789012:key/test-key-1", aws_iam_policy.cloudtrail[0].policy))
    error_message = "CloudTrail policy should contain the first KMS ARN"
  }

  assert {
    condition     = can(regex("arn:aws:kms:eu-west-1:123456789012:key/test-key-2", aws_iam_policy.cloudtrail[0].policy))
    error_message = "CloudTrail policy should contain the second KMS ARN"
  }
}
