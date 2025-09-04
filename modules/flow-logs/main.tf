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

  managed_policy_arns = [aws_iam_policy.default.arn]
  tags                = var.darktrace_cloud_security_tags
}

resource "aws_iam_policy" "default" {
  name        = "DarktraceFlowLogsPolicy"
  description = "Darktrace/Cloud Flow Logs Policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = concat([
      {
        Sid      = "AdaEcsAccessForMetadataTracking"
        Effect   = "Allow"
        Action   = "account:ListRegions"
        Resource = "*"
      },
      {
        Sid    = "s3Actions"
        Effect = "Allow"
        Action = local.existing_flow_log_bucket == false ? concat(local.s3_default_actions, local.s3_additional_actions) : local.s3_default_actions
        Resource = local.existing_flow_log_bucket == true ? flatten([
          for bucket in var.existing_flow_log_bucket_name : [
            "arn:aws:s3:::${bucket}*",
            "arn:aws:s3:::${bucket}*/*"
          ]
          ]) : [
          "arn:aws:s3:::darktrace-flowlogs*",
          "arn:aws:s3:::darktrace-flowlogs*/*"
        ]
      },
      {
        Sid    = "ec2Actions"
        Effect = "Allow"
        Action = local.existing_flow_log_bucket == false ? concat(local.ec2_default_actions, local.ec2_additional_actions) : local.ec2_default_actions
        Resource = [
          "*"
        ]
      }],
      # Only created if customer is not bringing their own Flow Log Bucket
      local.existing_flow_log_bucket == false ? [
        {
          Effect = "Allow"
          Action = [
            "ec2:DeleteFlowLogs",
            "route53resolver:DeleteResolverQueryLogConfig",
            "route53resolver:DisassociateResolverQueryLogConfig"
          ]
          Resource = [
            "*"
          ]
          Condition = {
            StringLike = {
              "aws:ResourceTag/Darktrace::Costing" = "CloudSecurityInfrastructure"
            }
          }
        },
        {
          Effect = "Allow"
          Action = [
            "iam:CreateServiceLinkedRole"
          ]
          Resource = [
            "arn:aws:iam::*:role/aws-service-role/route53resolver.amazonaws.com/*"
          ]
          Condition = {
            StringLike = {
              "iam:AWSServiceName" = "route53resolver.amazonaws.com"
            }
          }
        },
        {
          Effect = "Allow"
          Action = [
            "iam:AttachRolePolicy",
            "iam:PutRolePolicy"
          ]
          Resource = [
            "arn:aws:iam::*:role/aws-service-role/route53resolver.amazonaws.com/*"
          ]
          Condition = {
            StringLike = {
              "iam:AWSServiceName" = "route53resolver.amazonaws.com"
            }
          }
        }
      ] : []
    )
  })

  tags = var.darktrace_cloud_security_tags
}
