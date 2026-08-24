mock_provider "aws" {}

run "module_respond_defaults" {
  command = plan

  providers = {
    aws = aws
  }

  module {
    source = "./modules/respond"
  }

  variables {
    darktrace_cloud_security_core_iam_role_arn = "arn:aws:iam::123456789012:role/test-role"
  }

  assert {
    condition     = aws_iam_role.default.name == "DarktraceCloudRespondRole"
    error_message = "IAM role name should be DarktraceCloudRespondRole"
  }

  assert {
    condition     = aws_iam_policy.default.name == "DarktraceCloudRespondPolicy"
    error_message = "IAM policy name should be DarktraceCloudRespondPolicy"
  }
}
