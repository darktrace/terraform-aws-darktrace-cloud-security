locals {
  account_id = data.aws_caller_identity.current.account_id
  region     = data.aws_region.current.region

  # Setup type flags (exactly one is true for valid input combinations)
  dt_managed       = length(var.sqs_queue_arns) == 0 && var.flow_logs_bucket_name == null
  create_flow_logs = length(var.sqs_queue_arns) > 0 && var.flow_logs_bucket_name != null
  custom_sqs       = length(var.sqs_queue_arns) > 0 && var.flow_logs_bucket_name == null

  # ──────────────────────────────────────────────
  # Type 1 (Darktrace Managed) action lists
  # ──────────────────────────────────────────────

  # SQS management actions — scoped to darktrace-*
  dt_managed_sqs_actions = [
    "sqs:DeleteMessage",
    "sqs:GetQueueUrl",
    "sqs:ReceiveMessage",
    "sqs:GetQueueAttributes",
    "sqs:CreateQueue",
    "sqs:TagQueue",
    "sqs:SetQueueAttributes",
    "sqs:ListQueues"
  ]

  # S3 management actions — scoped to darktrace-flowlogs*
  dt_managed_s3_actions = [
    "s3:GetBucketNotification",
    "s3:ListBucket",
    "s3:GetObject",
    "s3:GetBucketPolicy",
    "s3:PutBucketPolicy",
    "s3:GetLifecycleConfiguration",
    "s3:PutLifecycleConfiguration",
    "s3:PutBucketTagging",
    "s3:GetBucketTagging",
    "s3:DeleteBucket",
    "s3:DeleteObject",
    "s3:PutBucketNotification"
  ]

  # Broad permissions — Resource: * (includes s3:CreateBucket)
  dt_managed_broad_actions = [
    "account:ListRegions",
    "ec2:DescribeVpcs",
    "ec2:CreateFlowLogs",
    "ec2:CreateTags",
    "ec2:DescribeFlowLogs",
    "ec2:DescribeSubnets",
    "ec2:DescribeNetworkInterfaces",
    "ec2:DescribeRouteTables",
    "ec2:DescribeVpcPeeringConnections",
    "ec2:DescribeTransitGatewayRouteTables",
    "ec2:DescribeTransitGatewayVpcAttachments",
    "ec2:GetTransitGatewayRouteTableAssociations",
    "ec2:SearchTransitGatewayRoutes",
    "s3:CreateBucket",
    "s3:ListAllMyBuckets",
    "logs:CreateLogDelivery",
    "route53resolver:AssociateResolverQueryLogConfig",
    "route53resolver:GetResolverQueryLogConfig",
    "route53resolver:GetResolverQueryLogConfigAssociation",
    "route53resolver:ListResolverQueryLogConfigAssociations",
    "route53resolver:CreateResolverQueryLogConfig",
    "route53resolver:ListResolverQueryLogConfigs",
    "route53resolver:TagResource",
    "cloudwatch:ListMetrics",
    "cloudwatch:GetMetricData",
    "cloudwatch:GetMetricStatistics",
    "autoscaling:DescribeAutoScalingGroups",
    "ec2:DescribeInstances",
    "ecs:ListClusters",
    "ecs:ListServices",
    "ecs:ListTasks",
    "ecs:DescribeTasks"
  ]

  # ──────────────────────────────────────────────
  # Type 2 (Create Flow Logs Only) action lists
  # ──────────────────────────────────────────────

  # SQS consume actions — scoped to customer ARNs
  create_flow_logs_sqs_actions = [
    "sqs:DeleteMessage",
    "sqs:GetQueueUrl",
    "sqs:ReceiveMessage"
  ]

  # Bucket-level actions — scoped to customer bucket
  create_flow_logs_bucket_actions = [
    "s3:ListBucket",
    "s3:GetObject",
    "s3:GetBucketPolicy",
    "s3:GetBucketNotification",
    "s3:GetBucketTagging",
    "s3:PutBucketNotification",
    "s3:PutBucketTagging"
  ]

  # Broad permissions — Resource: * (WITHOUT s3:CreateBucket)
  create_flow_logs_broad_actions = [
    "account:ListRegions",
    "ec2:DescribeVpcs",
    "ec2:CreateFlowLogs",
    "ec2:CreateTags",
    "ec2:DescribeFlowLogs",
    "ec2:DescribeSubnets",
    "ec2:DescribeNetworkInterfaces",
    "ec2:DescribeRouteTables",
    "ec2:DescribeVpcPeeringConnections",
    "ec2:DescribeTransitGatewayRouteTables",
    "ec2:DescribeTransitGatewayVpcAttachments",
    "ec2:GetTransitGatewayRouteTableAssociations",
    "ec2:SearchTransitGatewayRoutes",
    "s3:ListAllMyBuckets",
    "logs:CreateLogDelivery",
    "route53resolver:AssociateResolverQueryLogConfig",
    "route53resolver:GetResolverQueryLogConfig",
    "route53resolver:GetResolverQueryLogConfigAssociation",
    "route53resolver:ListResolverQueryLogConfigAssociations",
    "route53resolver:CreateResolverQueryLogConfig",
    "route53resolver:ListResolverQueryLogConfigs",
    "route53resolver:TagResource",
    "cloudwatch:ListMetrics",
    "cloudwatch:GetMetricData",
    "cloudwatch:GetMetricStatistics",
    "autoscaling:DescribeAutoScalingGroups",
    "ec2:DescribeInstances",
    "ecs:ListClusters",
    "ecs:ListServices",
    "ecs:ListTasks",
    "ecs:DescribeTasks"
  ]

  # ──────────────────────────────────────────────
  # Type 3 (Fully Custom) action lists
  # ──────────────────────────────────────────────

  # SQS consume actions — same as Type 2, scoped to customer ARNs
  custom_sqs_sqs_actions = [
    "sqs:DeleteMessage",
    "sqs:GetQueueUrl",
    "sqs:ReceiveMessage"
  ]

  # Broad read-only permissions — Resource: * (NO Create/Put/Delete/Tag/Associate)
  custom_sqs_broad_actions = [
    "account:ListRegions",
    "ec2:DescribeVpcs",
    "ec2:DescribeFlowLogs",
    "ec2:DescribeSubnets",
    "ec2:DescribeNetworkInterfaces",
    "ec2:DescribeRouteTables",
    "ec2:DescribeVpcPeeringConnections",
    "ec2:DescribeTransitGatewayRouteTables",
    "ec2:DescribeTransitGatewayVpcAttachments",
    "ec2:GetTransitGatewayRouteTableAssociations",
    "ec2:SearchTransitGatewayRoutes",
    "s3:ListAllMyBuckets",
    "route53resolver:GetResolverQueryLogConfig",
    "route53resolver:GetResolverQueryLogConfigAssociation",
    "route53resolver:ListResolverQueryLogConfigAssociations",
    "route53resolver:ListResolverQueryLogConfigs",
    "autoscaling:DescribeAutoScalingGroups",
    "ec2:DescribeInstances",
    "ecs:ListClusters",
    "ecs:ListServices",
    "ecs:ListTasks",
    "ecs:DescribeTasks"
  ]

  # ──────────────────────────────────────────────
  # Shared action lists
  # ──────────────────────────────────────────────

  # S3 object read actions — shared by Type 2 and Type 3, scoped to AWSLogs paths
  s3_object_read_actions = [
    "s3:GetObject"
  ]

  # Tag-conditioned delete actions — shared by Type 1 and Type 2
  tag_conditioned_delete_actions = [
    "ec2:DeleteFlowLogs",
    "route53resolver:DeleteResolverQueryLogConfig",
    "route53resolver:DisassociateResolverQueryLogConfig"
  ]

  # IAM service-linked role action — shared by Type 1 and Type 2
  iam_service_linked_role_actions = [
    "iam:CreateServiceLinkedRole"
  ]

  # IAM role policy attachment actions — shared by Type 1 and Type 2
  iam_role_policy_attachment_actions = [
    "iam:AttachRolePolicy",
    "iam:PutRolePolicy"
  ]
}
