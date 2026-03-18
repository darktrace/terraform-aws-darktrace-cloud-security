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

  tags = var.darktrace_cloud_security_tags
}

resource "aws_iam_role_policy_attachment" "security_audit" {
  role       = aws_iam_role.default.name
  policy_arn = "arn:aws:iam::aws:policy/SecurityAudit"
}

resource "aws_iam_role_policy_attachment" "default" {
  role       = aws_iam_role.default.name
  policy_arn = aws_iam_policy.default.arn
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
          "bedrock:GetAgent",
          "bedrock:GetAgentActionGroup",
          "bedrock:GetAgentVersion",
          "bedrock:GetBlueprint",
          "bedrock:GetDataAutomationProject",
          "bedrock:GetDataSource",
          "bedrock:GetEvaluationJob",
          "bedrock:GetFlow",
          "bedrock:GetFlowVersion",
          "bedrock:GetGuardrail",
          "bedrock:GetKnowledgeBase",
          "bedrock:GetModelInvocationJob",
          "bedrock:ListAgentCollaborators",
          "bedrock:ListBlueprints",
          "bedrock:ListDataAutomationProjects",
          "bedrock-agentcore:GetAgentRuntime",
          "bedrock-agentcore:GetAgentRuntimeEndpoint",
          "bedrock-agentcore:GetApiKeyCredentialProvider",
          "bedrock-agentcore:GetBrowser",
          "bedrock-agentcore:GetCodeInterpreter",
          "bedrock-agentcore:GetEvaluator",
          "bedrock-agentcore:GetGateway",
          "bedrock-agentcore:GetGatewayTarget",
          "bedrock-agentcore:GetMemory",
          "bedrock-agentcore:GetOauth2CredentialProvider",
          "bedrock-agentcore:GetOnlineEvaluationConfig",
          "bedrock-agentcore:GetPolicy",
          "bedrock-agentcore:GetPolicyEngine",
          "bedrock-agentcore:GetResourcePolicy",
          "bedrock-agentcore:GetTokenVault",
          "bedrock-agentcore:GetWorkloadIdentity",
          "bedrock-agentcore:ListAgentRuntimeEndpoints",
          "bedrock-agentcore:ListAgentRuntimes",
          "bedrock-agentcore:ListAgentRuntimeVersions",
          "bedrock-agentcore:ListApiKeyCredentialProviders",
          "bedrock-agentcore:ListBrowsers",
          "bedrock-agentcore:ListCodeInterpreters",
          "bedrock-agentcore:ListEvaluators",
          "bedrock-agentcore:ListGateways",
          "bedrock-agentcore:ListGatewayTargets",
          "bedrock-agentcore:ListMemories",
          "bedrock-agentcore:ListOauth2CredentialProviders",
          "bedrock-agentcore:ListOnlineEvaluationConfigs",
          "bedrock-agentcore:ListPolicies",
          "bedrock-agentcore:ListPolicyEngines",
          "bedrock-agentcore:ListTagsForResource",
          "bedrock-agentcore:ListWorkloadIdentities",
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
          "elasticbeanstalk:DescribeApplications",
          "elasticfilesystem:DescribeAccessPoints",
          "emr-containers:ListVirtualClusters",
          "emr-serverless:ListApplications",
          "glue:GetConnections",
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
          "lambda:GetFunctionUrlConfig",
          "lightsail:GetStaticIps",
          "logs:FilterLogEvents",
          "macie2:ListFindings",
          "macie2:GetMacieSession",
          "macie2:GetAdministratorAccount",
          "macie2:GetFindings",
          "macie2:GetClassificationExportConfiguration",
          "macie2:GetFindingsPublicationConfiguration",
          "qldb:ListLedgers",
          "s3:ListAccessGrants",
          "s3:ListAccessGrantsInstances",
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
          "vpc-lattice:ListServices",
          "vpc-lattice:ListNetworks",
          "vpc-lattice:ListServiceNetworkServiceAssociations",
          "vpc-lattice:ListServiceNetworkResourceAssociations",
          "vpc-lattice:ListResourceEndpointAssociations",
          "vpc-lattice:ListTargetGroups",
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
    )
  })

  tags = var.darktrace_cloud_security_tags
}
