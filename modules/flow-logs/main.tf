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
    Statement = [
      {
        Sid      = "AdaEcsAccessForMetadataTracking"
        Effect   = "Allow"
        Action   = "account:ListRegions"
        Resource = "*"
      },
      {
        Sid    = "sqsActions"
        Effect = "Allow"
        Action = [
          "sqs:DeleteMessage",
          "sqs:GetQueueUrl",
          "sqs:ReceiveMessage",
          "sqs:GetQueueAttributes",
          "sqs:CreateQueue",
          "sqs:TagQueue",
          "sqs:SetQueueAttributes",
          "sqs:ListQueues"
        ]
        Resource = "arn:aws:sqs:*:*:darktrace-*"
      },
      {
        Sid    = "s3Actions"
        Effect = "Allow"
        Action = concat(local.s3_default_actions, local.s3_additional_actions)
        Resource = [
          "arn:aws:s3:::darktrace-flowlogs-${local.account_id}",
          "arn:aws:s3:::darktrace-flowlogs-${local.account_id}/*"
        ]
      },
      {
        Sid    = "ec2Actions"
        Effect = "Allow"
        Action = concat(local.ec2_default_actions, local.ec2_additional_actions)
        Resource = [
          "*"
        ]
      },
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
      }
    ]
  })

  tags = var.darktrace_cloud_security_tags
}
