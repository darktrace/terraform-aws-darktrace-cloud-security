locals {
  cloudtrail_sqs_queue_name = "darktrace-cloudtrail-queue"
}

resource "aws_sqs_queue" "default" {
  count  = local.dt_managed && var.setup_cloudtrail ? 1 : 0
  name   = local.cloudtrail_sqs_queue_name
  policy = data.aws_iam_policy_document.default[0].json
}

data "aws_iam_policy_document" "default" {
  count = local.dt_managed && var.setup_cloudtrail ? 1 : 0
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["s3.amazonaws.com"]
    }


    actions   = ["sqs:SendMessage"]
    resources = ["arn:aws:sqs:${local.region}:${local.account_id}:${local.cloudtrail_sqs_queue_name}"]

    condition {
      test     = "ArnEquals"
      variable = "aws:SourceArn"
      values   = ["arn:aws:s3:::${coalesce(var.existing_cloudtrail_bucket_name, try(aws_s3_bucket.default[0].id, ""))}"]
    }
  }
}

resource "aws_s3_bucket_notification" "default" {
  # We do not configure bucket notifications for a customer's infrastructure
  count  = local.dt_managed && var.setup_cloudtrail ? 1 : 0
  bucket = try(aws_s3_bucket.default[0].id, "")

  queue {
    queue_arn = try(aws_sqs_queue.default[0].arn, "")
    events    = ["s3:ObjectCreated:*"]
  }
}
