resource "aws_cloudtrail" "default" {
  count = local.dt_managed && var.setup_cloudtrail ? 1 : 0

  name           = "DarktraceTrail"
  s3_bucket_name = coalesce(var.existing_cloudtrail_bucket_name, try(aws_s3_bucket.default[0].id, ""))

  enable_logging                = true
  enable_log_file_validation    = true
  include_global_service_events = true
  is_multi_region_trail         = true
  is_organization_trail         = var.is_organization_admin_account

  # Management events
  advanced_event_selector {
    name = "Log management events for Darktrace /CLOUD"

    field_selector {
      field  = "eventCategory"
      equals = ["Management"]
    }
  }

  # Data events per resource type
  dynamic "advanced_event_selector" {
    for_each = local.cloudtrail_data_resource_types
    content {
      name = "Log ${advanced_event_selector.value} Data events for Darktrace ⁄CLOUD"

      field_selector {
        field  = "eventCategory"
        equals = ["Data"]
      }

      field_selector {
        field  = "resources.type"
        equals = [advanced_event_selector.value]
      }
    }
  }

  # Network activity events per event source
  dynamic "advanced_event_selector" {
    for_each = local.cloudtrail_network_event_sources
    content {
      name = "Log ${split(".", advanced_event_selector.value)[0]} Network events for Darktrace ⁄CLOUD"

      field_selector {
        field  = "eventCategory"
        equals = ["NetworkActivity"]
      }

      field_selector {
        field  = "eventSource"
        equals = [advanced_event_selector.value]
      }
    }
  }

  tags = var.darktrace_cloud_security_tags

  depends_on = [aws_s3_bucket_policy.default]
}

resource "aws_iam_role" "cloudtrail" {
  count = var.setup_cloudtrail ? 1 : 0

  name        = "DarktraceCloudTrailRole"
  description = "Darktrace /CLOUD CloudTrail Role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          AWS = aws_iam_role.default.arn
        }
      }
    ]
  })

  tags = var.darktrace_cloud_security_tags

  lifecycle {
    precondition {
      condition = (var.existing_cloudtrail_name != null && var.existing_cloudtrail_bucket_name != null ||
      var.existing_cloudtrail_name == null && var.existing_cloudtrail_bucket_name == null)
      error_message = "If existing_cloudtrail_name is provided then existing_cloudtrial_bucket_name is required. If not then both must be undefined"
    }
  }
}

resource "aws_iam_role_policy_attachment" "cloudtrail" {
  count = var.setup_cloudtrail ? 1 : 0

  role       = aws_iam_role.cloudtrail[0].name
  policy_arn = aws_iam_policy.cloudtrail[0].arn
}

resource "aws_iam_policy" "cloudtrail" {
  count = var.setup_cloudtrail ? 1 : 0

  name        = "DarktraceCloudTrailPolicy"
  description = "Darktrace /CLOUD CloudTrail Policy"

  policy = jsonencode({
    Version = "2012-10-17"
    # Some statements are added conditionally, we filter out nulls at the end
    Statement = concat([
      {
        Action = [
          "cloudtrail:DescribeTrails"
        ]
        Resource = "*"
        Effect   = "Allow"
      },
      {
        Action = [for action in [
          "s3:GetLifecycleConfiguration",
          "s3:GetObject",
          # We only have write bucket permission for DT Managed deployments
          local.dt_managed ? "s3:PutLifecycleConfiguration" : null,
          # We only have ListBucket permissions where SQS is not used
          var.existing_cloudtrail_bucket_sqs_arn == null && !local.dt_managed ? "s3:ListBucket" : null
        ] : action if action != null]
        Resource = [
          "arn:aws:s3:::${coalesce(var.existing_cloudtrail_bucket_name, try(aws_s3_bucket.default[0].id, ""))}/*",
          "arn:aws:s3:::${coalesce(var.existing_cloudtrail_bucket_name, try(aws_s3_bucket.default[0].id, ""))}"
        ]
        Effect = "Allow"
      }],
      var.is_organization_admin_account ? [{
        Action = [
          "organizations:ListAccounts"
        ]
        Resource = "*"
        Effect   = "Allow"
      }] : [],
      local.dt_managed || var.existing_cloudtrail_bucket_sqs_arn != null ? [{
        Action = [
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage"
        ]
        Resource = [
          coalesce(var.existing_cloudtrail_bucket_sqs_arn, try(one(aws_sqs_queue.default[*].arn), ""))
        ]
        Effect = "Allow"
      }] : [],
      var.autoconfigure_cloudtrail ? [{
        Action = [
          "cloudtrail:GetEventSelectors",
          "cloudtrail:PutEventSelectors"
        ]
        Resource = [
          "arn:aws:cloudtrail:*:*:trail/${coalesce(var.existing_cloudtrail_name, try(aws_cloudtrail.default[0].name, ""))}"
        ]
        Effect = "Allow"
      }] : [],
      length(var.kms_arns) > 0 ? [{
        Action = [
          "kms:Decrypt"
        ]
        Resource = var.kms_arns
        Effect   = "Allow"
      }] : []
    )
  })

  tags = var.darktrace_cloud_security_tags
}
