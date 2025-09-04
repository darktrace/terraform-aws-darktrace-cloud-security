#
# IAM
#

resource "aws_iam_role" "default" {
  name        = "DarktraceRole"
  description = "Darktrace/Cloud Core Role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          AWS = var.darktrace_cloud_security_aws_account_id
        }
        Condition = {
          StringEquals = {
            "sts:ExternalId" = var.darktrace_cloud_security_external_id
          }
        }
      }
    ]
  })

  managed_policy_arns = [
    aws_iam_policy.default.arn,
    "arn:aws:iam::aws:policy/SecurityAudit"
  ]
  tags = var.darktrace_cloud_security_tags
}

resource "aws_iam_policy" "default" {
  name        = "DarktracePolicy"
  description = "Darktrace/Cloud Core Policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = concat([
      {
        Effect = "Allow"
        Action = [
          "apigateway:GET",
          "athena:GetDataCatalog",
          "athena:GetDataCatalog",
          "athena:GetWorkGroup",
          "athena:ListDataCatalogs",
          "athena:ListDatabases",
          "bedrock:ListAgents",
          "bedrock:GetAgent",
          "bedrock:ListAgentAliases",
          "bedrock:GetAgentAlias",
          "bedrock:ListKnowledgeBases",
          "bedrock:GetKnowledgeBase",
          "bedrock:ListDataSources",
          "bedrock:GetDataSource",
          "bedrock:ListFlows",
          "bedrock:GetFlow",
          "bedrock:ListFlowAliases",
          "bedrock:GetFlowAlias",
          "bedrock:ListFlowVersions",
          "bedrock:GetFlowVersion",
          "bedrock:ListGuardrails",
          "bedrock:GetGuardrail",
          "bedrock:ListCustomModels",
          "bedrock:GetCustomModel",
          "bedrock:ListEvaluationJobs",
          "bedrock:GetEvaluationJob",
          "bedrock:ListFoundationModels",
          "bedrock:GetFoundationModel",
          "bedrock:ListImportedModels",
          "bedrock:GetImportedModel",
          "bedrock:ListModelCopyJobs",
          "bedrock:ListModelCustomizationJobs",
          "bedrock:GetModelCustomizationJob",
          "bedrock:ListModelImportJobs",
          "bedrock:GetModelImportJob",
          "bedrock:ListModelInvocationJobs",
          "bedrock:GetModelInvocationJob",
          "bedrock:ListProvisionedModelThroughputs",
          "bedrock:ListBlueprints",
          "bedrock:GetBlueprint",
          "bedrock:ListDataAutomationProjects",
          "bedrock:GetDataAutomationProject",
          "ce:GetCostAndUsage",
          "ce:GetCostAndUsageWithResources",
          "ce:GetCostCategories",
          "ce:GetDimensionValues",
          "ce:GetSavingsPlansUtilization",
          "ce:GetTags",
          "ce:ListTagsForResource",
          "cloudwatch:ListManagedInsightRules",
          "cloudwatch:ListMetrics",
          "cloudwatch:GetMetricData",
          "cloudwatch:GetMetricStatistics",
          "cloudwatch:GetMetricStream",
          "cloudwatch:ListMetricStreams",
          "cloudwatch:ListTagsForResource",
          "codebuild:BatchGetBuilds",
          "codebuild:BatchGetProjects",
          "codebuild:ListBuilds",
          "cognito-identity:ListIdentities",
          "config:DescribeConformancePacks",
          "ec2:GetTransitGatewayPolicyTableEntries",
          "ec2:SearchTransitGatewayRoutes",
          "ecr:DescribeRegistry",
          "ecr:GetRegistryPolicy",
          "eks:DescribeFargateProfile",
          "eks:ListFargateProfiles",
          "emr-containers:ListVirtualClusters",
          "emr-serverless:ListApplications",
          "glue:GetDevEndpoint",
          "glue:GetJob",
          "glue:GetMLTransforms",
          "glue:GetSecurityConfiguration",
          "glue:GetTables",
          "glue:GetTriggers",
          "glue:ListDevEndpoints",
          "glue:ListRegistries",
          "glue:ListSchemas",
          "kms:GetKeyRotationStatus",
          "lambda:GetFunction",
          "logs:FilterLogEvents",
          "macie2:ListFindings",
          "macie2:GetMacieSession",
          "macie2:GetAdministratorAccount",
          "macie2:GetFindings",
          "macie2:GetClassificationExportConfiguration",
          "macie2:GetFindingsPublicationConfiguration",
          "qldb:ListLedgers",
          "sagemaker:GetModelPackageGroupPolicy",
          "servicecatalog:DescribePortfolio",
          "servicecatalog:ListPortfolios",
          "servicediscovery:ListInstances",
          "servicediscovery:ListNamespaces",
          "servicediscovery:ListServices",
          "states:ListActivities",
          "tag:GetResources",
          "tag:GetTagKeys",
          "tag:GetTagValues",
          "waf-regional:ListRateBasedRules",
          "waf-regional:ListRuleGroups",
          "waf-regional:ListRules",
          "waf:ListRateBasedRules",
          "waf:ListRuleGroups",
          "waf:ListRules",
          "wafv2:GetRuleGroup",
          "wafv2:ListResourcesForWebACL"
        ],
        Resource = [
          "*"
        ]
      }],
      # Only created if is_organization_admin_account is true
      var.is_organization_admin_account ? [
        {
          Effect = "Allow"
          Action = [
            "organizations:ListAccounts"
          ],
          Resource = [
            "*"
          ]
        }
      ] : [],
      # Only created if setup_cloudtrail is true
      var.setup_cloudtrail ? [
        {
          Effect = "Allow"
          Action = concat(
            [
              "s3:GetLifecycleConfiguration",
              "s3:GetObject",
              "s3:ListObject",
              "s3:ListBucket"
            ],
            # Only created if autoconfigure_cloudtrail is true
            var.autoconfigure_cloudtrail ? ["s3:PutLifecycleConfiguration"] : []
          )
          Resource = [
            "arn:aws:s3:::${coalesce(var.existing_cloudtrail_bucket_name, try(aws_s3_bucket.default[0].bucket, ""))}/*",
            "arn:aws:s3:::${coalesce(var.existing_cloudtrail_bucket_name, try(aws_s3_bucket.default[0].bucket, ""))}"
          ]
        },
        {
          Effect = "Allow"
          Action = [
            "cloudtrail:DescribeTrails"
          ],
          Resource = [
            "*"
          ]
        },
        {
          Effect = "Allow"
          Action = concat(
            ["cloudtrail:GetEventSelectors"],
            # Only created if autoconfigure_cloudtrail is true
            var.autoconfigure_cloudtrail ? ["cloudtrail:PutEventSelectors"] : []
          )
          Resource = [
            "arn:aws:cloudtrail:*:*:trail/${coalesce(var.existing_cloudtrail_name, try(aws_cloudtrail.default[0].name, ""))}"
          ]
        }
      ] : [],
      # Only created if setup_cloudtrail and setup_sqs is true
      var.setup_cloudtrail == true && var.setup_sqs == true ? [
        {
          Effect = "Allow"
          Action = [
            "sqs:ReceiveMessage",
            "sqs:DeleteMessage"
          ]
          Resource = [one(aws_sqs_queue.default[*].arn)]
        }
      ] : [],
      {
        Sid    = "AdaEcsAccessForEcsAndAutoscalingMetadataTracking"
        Effect = "Allow"
        Action = [
          "account:ListRegions",
          "autoscaling:DescribeAutoScalingGroups",
          "ec2:DescribeInstances",
          "ecs:ListClusters",
          "ecs:ListTasks",
          "ecs:DescribeTasks",
          "ec2:DescribeNetworkInterfaces",
          "ecs:ListServices"
        ]
        Resource = [
          "*"
        ]
      }
    )
  })

  tags = var.darktrace_cloud_security_tags
}

#
# s3
#

resource "aws_s3_bucket" "default" {
  count  = var.existing_cloudtrail_name == null && var.existing_cloudtrail_bucket_name == null && var.setup_cloudtrail == true ? 1 : 0
  bucket = "darktrace-bucket-${local.account_id}"

  tags = var.darktrace_cloud_security_tags
}

resource "aws_s3_bucket_versioning" "default" {
  count  = var.existing_cloudtrail_name == null && var.existing_cloudtrail_bucket_name == null && var.setup_cloudtrail == true ? 1 : 0
  bucket = aws_s3_bucket.default[0].id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "default" {
  count  = var.existing_cloudtrail_name == null && var.existing_cloudtrail_bucket_name == null && var.setup_cloudtrail == true ? 1 : 0
  bucket = aws_s3_bucket.default[0].id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "default" {
  count  = var.existing_cloudtrail_name == null && var.existing_cloudtrail_bucket_name == null && var.setup_cloudtrail == true ? 1 : 0
  bucket = aws_s3_bucket.default[0].id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_lifecycle_configuration" "default" {
  count  = var.existing_cloudtrail_name == null && var.existing_cloudtrail_bucket_name == null && var.setup_cloudtrail == true ? 1 : 0
  bucket = aws_s3_bucket.default[0].id

  rule {
    status = "Enabled"
    id     = "DarktraceBucketLifecycle"
    expiration {
      days = 30
    }
    noncurrent_version_expiration {
      noncurrent_days = 30
    }
  }
}

resource "aws_s3_bucket_policy" "default" {
  count  = var.existing_cloudtrail_name == null && var.existing_cloudtrail_bucket_name == null && var.setup_cloudtrail == true ? 1 : 0
  bucket = aws_s3_bucket.default[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AWSCloudTrailAclCheck"
        Effect = "Allow"
        Action = "s3:GetBucketAcl"
        Resource = [
          aws_s3_bucket.default[0].arn
        ]
        Principal = {
          Service = "cloudtrail.amazonaws.com"
        }
      },
      {
        Sid    = "AWSCloudTrailWrite"
        Effect = "Allow"
        Action = "s3:PutObject"
        Resource = [
          "${aws_s3_bucket.default[0].arn}/AWSLogs/*"
        ]
        Condition = {
          StringEquals = {
            "s3:x-amz-acl" = "bucket-owner-full-control"
          }
        }
        Principal = {
          Service = "cloudtrail.amazonaws.com"
        }
      }
    ]
  })
}

#
# SQS
#
resource "aws_sqs_queue" "default" {
  count  = var.existing_cloudtrail_name == null && var.existing_cloudtrail_bucket_name == null && var.setup_cloudtrail == true && var.setup_sqs == true ? 1 : 0
  name   = local.sqs_queue_name
  policy = data.aws_iam_policy_document.default[0].json
}

data "aws_iam_policy_document" "default" {
  count = var.existing_cloudtrail_name == null && var.existing_cloudtrail_bucket_name == null && var.setup_cloudtrail == true && var.setup_sqs == true ? 1 : 0
  statement {
    effect = "Allow"

    principals {
      type = "AWS"
      identifiers = [
        local.account_id
      ]
    }

    actions   = ["sqs:SendMessage"]
    resources = ["arn:aws:sqs:${local.region}:${local.account_id}:${local.sqs_queue_name}"]

    condition {
      test     = "ArnEquals"
      variable = "aws:SourceArn"
      values   = [aws_s3_bucket.default[0].arn]
    }
  }
}

resource "aws_s3_bucket_notification" "default" {
  count  = var.existing_cloudtrail_name == null && var.existing_cloudtrail_bucket_name == null && var.setup_cloudtrail == true && var.setup_sqs == true ? 1 : 0
  bucket = aws_s3_bucket.default[0].id

  queue {
    queue_arn = aws_sqs_queue.default[0].arn
    events    = ["s3:ObjectCreated:*"]
  }
}

#
# CloudTrail
#
resource "aws_cloudtrail" "default" {
  count = var.existing_cloudtrail_name == null && var.existing_cloudtrail_bucket_name == null && var.setup_cloudtrail == true ? 1 : 0

  name           = "DarktraceTrail"
  s3_bucket_name = aws_s3_bucket.default[0].bucket

  enable_logging                = true
  include_global_service_events = true
  is_multi_region_trail         = true
  is_organization_trail         = var.is_organization_admin_account

  event_selector {
    data_resource {
      type   = "AWS::S3::Object"
      values = ["arn:aws:s3"]
    }

    data_resource {
      type   = "AWS::Lambda::Function"
      values = ["arn:aws:lambda"]
    }

    include_management_events = true
    read_write_type           = "All"
  }

  tags = var.darktrace_cloud_security_tags

  depends_on = [aws_s3_bucket_policy.default[0]]
}
