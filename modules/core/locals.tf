locals {
  account_id = data.aws_caller_identity.current.account_id
  region     = data.aws_region.current.region
  dt_managed = var.existing_cloudtrail_name == null

  # Data event resource types for advanced event selectors
  cloudtrail_data_resource_types = [
    "AWS::S3::Object",
    "AWS::Lambda::Function",
    "AWS::Bedrock::AgentAlias",
    "AWS::Bedrock::AsyncInvoke",
    "AWS::Bedrock::FlowAlias",
    "AWS::Bedrock::Guardrail",
    "AWS::Bedrock::InlineAgent",
    "AWS::Bedrock::KnowledgeBase",
    "AWS::Bedrock::Model",
    "AWS::Bedrock::PromptVersion",
    "AWS::SES::ConfigurationSet",
    "AWS::SES::EmailIdentity",
    "AWS::SES::Template",
    "AWS::SMSVoice::OriginationIdentity",
  ]

  # Network activity event sources for advanced event selectors
  cloudtrail_network_event_sources = [
    "bedrock.amazonaws.com",
    "lambda.amazonaws.com",
  ]
}
