#
# IAM
#

resource "aws_iam_role" "default" {
  name        = "DarktraceFlowLogsRole"
  description = "Darktrace/Cloud Flow Logs Role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          AWS = var.darktrace_cloud_security_core_iam_role_arn
        }
      }
    ]
  })

  lifecycle {
    precondition {
      condition     = !(length(var.sqs_queue_arns) == 0 && var.flow_logs_bucket_name != null)
      error_message = "flow_logs_bucket_name requires sqs_queue_arns to be provided. Provide both for 'Create Flow Logs Only' setup, or neither for 'Darktrace Managed' setup."
    }
  }

  tags = var.darktrace_cloud_security_tags
}

resource "aws_iam_role_policy_attachment" "default" {
  role       = aws_iam_role.default.name
  policy_arn = aws_iam_policy.default.arn
}

resource "aws_iam_policy" "default" {
  name        = "DarktraceFlowLogsPolicy"
  description = "Darktrace/Cloud Flow Logs Policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = concat(
      # AdaEcsAccessForMetadataTracking — present for all types
      [
        {
          Sid      = "AdaEcsAccessForMetadataTracking"
          Effect   = "Allow"
          Action   = "account:ListRegions"
          Resource = "*"
        }
      ],

      # Type 1: Darktrace Managed — SQS management
      local.dt_managed ? [{
        Sid      = "sqsManagement"
        Effect   = "Allow"
        Action   = local.dt_managed_sqs_actions
        Resource = "arn:aws:sqs:*:*:darktrace-*"
      }] : [],

      # Type 1: Darktrace Managed — S3 management
      local.dt_managed ? [{
        Sid    = "s3Management"
        Effect = "Allow"
        Action = local.dt_managed_s3_actions
        Resource = [
          "arn:aws:s3:::darktrace-flowlogs-${local.account_id}",
          "arn:aws:s3:::darktrace-flowlogs-${local.account_id}/*"
        ]
      }] : [],

      # Type 1: Darktrace Managed — broad permissions (incl. s3:CreateBucket)
      local.dt_managed ? [{
        Sid      = "broadPermissions"
        Effect   = "Allow"
        Action   = local.dt_managed_broad_actions
        Resource = "*"
      }] : [],

      # Type 1 & 2: Tag-conditioned delete
      local.dt_managed || local.create_flow_logs ? [{
        Sid      = "tagConditionedDelete"
        Effect   = "Allow"
        Action   = local.tag_conditioned_delete_actions
        Resource = "*"
        Condition = {
          StringLike = {
            "aws:ResourceTag/Darktrace::Costing" = "CloudSecurityInfrastructure"
          }
        }
      }] : [],

      # Type 1 & 2: IAM service-linked role
      local.dt_managed || local.create_flow_logs ? [{
        Sid      = "iamServiceLinkedRole"
        Effect   = "Allow"
        Action   = local.iam_service_linked_role_actions
        Resource = "arn:aws:iam::*:role/aws-service-role/route53resolver.amazonaws.com/*"
        Condition = {
          StringLike = {
            "iam:AWSServiceName" = "route53resolver.amazonaws.com"
          }
        }
      }] : [],

      # Type 1 & 2: IAM role policy attachment
      local.dt_managed || local.create_flow_logs ? [{
        Sid      = "iamRolePolicyAttachment"
        Effect   = "Allow"
        Action   = local.iam_role_policy_attachment_actions
        Resource = "arn:aws:iam::*:role/aws-service-role/route53resolver.amazonaws.com/*"
      }] : [],

      # Type 2 & 3: S3 object read
      local.create_flow_logs || local.custom_sqs ? [{
        Sid    = "s3ObjectRead"
        Effect = "Allow"
        Action = local.s3_object_read_actions
        Resource = [
          "arn:aws:s3:::*/AWSLogs/*/vpcflowlogs/*",
          "arn:aws:s3:::*/AWSLogs/*/vpcdnsquerylogs/*"
        ]
      }] : [],

      # Type 2: Create Flow Logs Only — SQS consume (customer ARNs)
      local.create_flow_logs ? [{
        Sid      = "sqsConsume"
        Effect   = "Allow"
        Action   = local.create_flow_logs_sqs_actions
        Resource = var.sqs_queue_arns
      }] : [],

      # Type 2: Create Flow Logs Only — bucket-level permissions
      local.create_flow_logs ? [{
        Sid    = "bucketLevelPermissions"
        Effect = "Allow"
        Action = local.create_flow_logs_bucket_actions
        Resource = [
          "arn:aws:s3:::${var.flow_logs_bucket_name != null ? var.flow_logs_bucket_name : ""}",
          "arn:aws:s3:::${var.flow_logs_bucket_name != null ? var.flow_logs_bucket_name : ""}/*"
        ]
      }] : [],

      # Type 2: Create Flow Logs Only — broad permissions (no s3:CreateBucket)
      local.create_flow_logs ? [{
        Sid      = "broadPermissions"
        Effect   = "Allow"
        Action   = local.create_flow_logs_broad_actions
        Resource = "*"
      }] : [],

      # Type 3: Fully Custom — SQS consume (customer ARNs)
      local.custom_sqs ? [{
        Sid      = "sqsConsume"
        Effect   = "Allow"
        Action   = local.custom_sqs_sqs_actions
        Resource = var.sqs_queue_arns
      }] : [],

      # Type 3: Fully Custom — broad read-only permissions
      local.custom_sqs ? [{
        Sid      = "broadReadOnly"
        Effect   = "Allow"
        Action   = local.custom_sqs_broad_actions
        Resource = "*"
      }] : [],

      # KMS decrypt (conditional, appended to any type)
      length(var.kms_arns) > 0 ? [{
        Sid      = "kmsDecrypt"
        Effect   = "Allow"
        Action   = "kms:Decrypt"
        Resource = var.kms_arns
      }] : []
    )
  })

  tags = var.darktrace_cloud_security_tags
}
