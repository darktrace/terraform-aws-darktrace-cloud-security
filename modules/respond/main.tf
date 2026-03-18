#
# IAM
#

resource "aws_iam_role" "default" {
  name        = "DarktraceCloudRespondRole"
  description = "Darktrace/Cloud RESPOND Role"

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
  name        = "DarktraceCloudRespondPolicy"
  description = "Darktrace/Cloud RESPOND Managed Policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ec2:AssociateIamInstanceProfile",
          "ec2:AuthorizeSecurityGroupEgress",
          "ec2:AuthorizeSecurityGroupIngress",
          "ec2:CreateNetworkAclEntry",
          "ec2:CreateSecurityGroup",
          "ec2:CreateTags",
          "ec2:DeleteNetworkAclEntry",
          "ec2:DeleteSecurityGroup",
          "ec2:DescribeIamInstanceProfileAssociations",
          "ec2:DescribeInstances",
          "ec2:DescribeNetworkAcls",
          "ec2:DescribeNetworkInterfaces",
          "ec2:DescribeSecurityGroups",
          "ec2:DisassociateIamInstanceProfile",
          "ec2:ModifyInstanceAttribute",
          "ec2:ModifyNetworkInterfaceAttribute",
          "ec2:ReplaceNetworkAclEntry",
          "ec2:RevokeSecurityGroupEgress",
          "ec2:DescribeSubnets",
          "ecs:DescribeServices",
          "ecs:UpdateService",
          "iam:AttachRolePolicy",
          "iam:AttachUserPolicy",
          "iam:CreatePolicy",
          "iam:DeletePolicy",
          "iam:DetachRolePolicy",
          "iam:DetachUserPolicy",
          "iam:ListEntitiesForPolicy",
          "iam:PassRole",
          "lambda:DeleteFunctionConcurrency",
          "lambda:GetFunctionConcurrency",
          "lambda:PutFunctionConcurrency",
          "s3:GetBucketPublicAccessBlock",
          "s3:PutBucketPublicAccessBlock"
        ]
        Resource = "*"
        Effect   = "Allow"
      }
    ]
  })

  tags = var.darktrace_cloud_security_tags
}
