mock_provider "aws" {}

override_data {
  target = data.aws_iam_policy_document.default[0]
  values = {
    json = "{}"
  }
}

# Advanced Event Selector Tests
# These tests validate the CloudTrail advanced event selectors.
# They are forwards-compatible: assertions check structural properties
# rather than hardcoded counts, so adding or removing selectors from
# the locals lists will not break unrelated assertions.

run "advanced_selectors_default" {
  command = plan

  module {
    source = "./modules/core"
  }

  variables {
    darktrace_cloud_security_aws_account_id = "123456789012"
    darktrace_cloud_security_external_id    = "test-external-id"
    setup_cloudtrail                        = true
  }

  # Property: Management event selector exists
  assert {
    condition = anytrue([
      for s in aws_cloudtrail.default[0].advanced_event_selector :
      s.name == "Log management events for Darktrace /CLOUD"
    ])
    error_message = "CloudTrail should have a management events advanced event selector"
  }

  # Property: At least one Data event selector exists
  assert {
    condition = anytrue([
      for s in aws_cloudtrail.default[0].advanced_event_selector :
      can(regex("Data events for Darktrace", s.name))
    ])
    error_message = "CloudTrail should have at least one data event selector"
  }

  # Property: At least one Network activity selector exists
  assert {
    condition = anytrue([
      for s in aws_cloudtrail.default[0].advanced_event_selector :
      can(regex("Network events for Darktrace", s.name))
    ])
    error_message = "CloudTrail should have at least one network activity event selector"
  }

  # Property: Every data event selector has eventCategory=Data and a resources.type field
  assert {
    condition = alltrue([
      for s in aws_cloudtrail.default[0].advanced_event_selector :
      !can(regex("Data events for Darktrace", s.name)) || (
        anytrue([for fs in s.field_selector : fs.field == "eventCategory" && contains(fs.equals, "Data")]) &&
        anytrue([for fs in s.field_selector : fs.field == "resources.type"])
      )
    ])
    error_message = "Every data event selector must have eventCategory=Data and a resources.type field_selector"
  }

  # Property: Every network activity selector has eventCategory=NetworkActivity and an eventSource field
  assert {
    condition = alltrue([
      for s in aws_cloudtrail.default[0].advanced_event_selector :
      !can(regex("Network events for Darktrace", s.name)) || (
        anytrue([for fs in s.field_selector : fs.field == "eventCategory" && contains(fs.equals, "NetworkActivity")]) &&
        anytrue([for fs in s.field_selector : fs.field == "eventSource"])
      )
    ])
    error_message = "Every network activity selector must have eventCategory=NetworkActivity and an eventSource field_selector"
  }
}

run "advanced_selectors_not_created_for_existing_trail" {
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

  # Property: No CloudTrail resource created when using existing trail
  assert {
    condition     = length(aws_cloudtrail.default) == 0
    error_message = "CloudTrail should not be created when using existing trail, so no advanced event selectors should exist"
  }
}
