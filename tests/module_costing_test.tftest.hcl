mock_provider "aws" {}

override_data {
  target = data.aws_region.current
  values = {
    region = "us-east-1"
  }
}

run "module_costing_defaults" {
  command = plan

  providers = {
    aws           = aws
    aws.us_east_1 = aws
  }

  module {
    source = "./modules/costing"
  }

  variables {
    darktrace_cloud_security_core_iam_role_arn = "arn:aws:iam::123456789012:role/test-role"
  }

  assert {
    condition     = aws_iam_role.default.name == "DarktraceCloudCostingRole"
    error_message = "IAM role name should be DarktraceCloudCostingRole"
  }

  assert {
    condition     = length(aws_s3_bucket.default) > 0
    error_message = "S3 bucket should be created"
  }

  assert {
    condition     = length(aws_cur_report_definition.default) > 0
    error_message = "Cost + Usage Report should be created"
  }
}

run "module_costing_with_existing_resources" {
  command = plan

  providers = {
    aws           = aws
    aws.us_east_1 = aws
  }

  module {
    source = "./modules/costing"
  }

  variables {
    darktrace_cloud_security_core_iam_role_arn = "arn:aws:iam::123456789012:role/test-role"
    existing_cur_bucket_name                   = "existing-bucket"
    existing_cur_report_name                   = "existing-report"
    existing_cur_bucket_prefix                 = "existing-prefix"
  }

  assert {
    condition     = length(aws_s3_bucket.default) == 0
    error_message = "S3 bucket should not be created when existing bucket is provided"
  }

  assert {
    condition     = length(aws_cur_report_definition.default) == 0
    error_message = "Cost + Usage Report should not be created when existing report is provided"
  }

  assert {
    condition     = aws_iam_role.default.name == "DarktraceCloudCostingRole"
    error_message = "IAM role should still be created"
  }
}
