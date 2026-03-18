locals {
  account_id = data.aws_caller_identity.current.account_id
  region     = data.aws_region.current.region

  s3_default_actions = [
    "s3:GetBucketNotification",
    "s3:ListBucket",
    "s3:GetObject",
    "s3:GetBucketPolicy",
    "s3:GetLifecycleConfiguration",
    "s3:GetBucketTagging"
  ]
  s3_additional_actions = [
    "s3:PutBucketPolicy",
    "s3:PutLifecycleConfiguration",
    "s3:PutBucketTagging",
    "s3:DeleteBucket",
    "s3:DeleteObject",
    "s3:PutBucketNotification"
  ]

  ec2_default_actions = [
    "ec2:DescribeVpcs",
    "ec2:DescribeFlowLogs",
    "ec2:DescribeSubnets",
    "ec2:DescribeNetworkInterfaces",
    "ec2:DescribeRouteTables",
    "ec2:DescribeVpcPeeringConnections",
    "ec2:DescribeInstances",
    "s3:ListAllMyBuckets",
    "route53resolver:GetResolverQueryLogConfig",
    "route53resolver:GetResolverQueryLogConfigAssociation",
    "route53resolver:ListResolverQueryLogConfigAssociations",
    "route53resolver:ListResolverQueryLogConfigs",
    "cloudwatch:ListMetrics",
    "cloudwatch:GetMetricData",
    "cloudwatch:GetMetricStatistics",
    "autoscaling:DescribeAutoScalingGroups",
    "ecs:ListClusters",
    "ecs:ListServices",
    "ecs:ListTasks",
    "ecs:DescribeTasks"
  ]
  ec2_additional_actions = [
    "ec2:CreateFlowLogs",
    "ec2:CreateTags",
    "s3:CreateBucket",
    "logs:CreateLogDelivery",
    "route53resolver:AssociateResolverQueryLogConfig",
    "route53resolver:CreateResolverQueryLogConfig",
    "route53resolver:TagResource"
  ]
}
