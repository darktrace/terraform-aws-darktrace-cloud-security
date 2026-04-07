#
# IAM
#

resource "aws_iam_role" "default" {
  name        = "DarktraceCloudCostingRole"
  description = "Darktrace/Cloud Costing Role"

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
  name        = "DarktraceCloudCostingPolicy"
  description = "Darktrace/Cloud Costing Policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowListCurBucket"
        Effect = "Allow"
        Action = [
          "s3:ListBucket"
        ]
        Resource = [
          "arn:aws:s3:::${coalesce(var.existing_cur_bucket_name, "darktrace-costing-${local.account_id}")}"
        ]
      },
      {
        Sid    = "AllowDownloadDeleteCur"
        Effect = "Allow"
        Action = concat(["s3:GetObject"], var.existing_cur_bucket_name == null ? ["s3:DeleteObject"] : [])
        Resource = [
          "arn:aws:s3:::${coalesce(var.existing_cur_bucket_name, "darktrace-costing-${local.account_id}")}/${coalesce(var.existing_cur_bucket_prefix, "reports")}/*"
        ]
      },
      {
        Sid    = "AllowDescribeCur"
        Effect = "Allow"
        Action = [
          "cur:DescribeReportDefinitions"
        ]
        Resource = [
          "*"
        ]
      }
    ]
  })

  tags = var.darktrace_cloud_security_tags
}

#
# s3
#
resource "aws_s3_bucket" "default" {
  count  = var.existing_cur_bucket_name == null ? 1 : 0
  bucket = "darktrace-costing-${local.account_id}"

  tags          = var.darktrace_cloud_security_tags
  provider      = aws.us_east_1
  force_destroy = true
}

resource "aws_s3_bucket_versioning" "default" {
  count  = var.existing_cur_bucket_name == null ? 1 : 0
  bucket = aws_s3_bucket.default[0].id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_public_access_block" "default" {
  count  = var.existing_cur_bucket_name == null ? 1 : 0
  bucket = aws_s3_bucket.default[0].id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_lifecycle_configuration" "default" {
  count  = var.existing_cur_bucket_name == null ? 1 : 0
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
  count  = var.existing_cur_bucket_name == null ? 1 : 0
  bucket = aws_s3_bucket.default[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowSSLRequestsOnly"
        Effect = "Deny"
        Action = "s3:*"
        Resource = [
          aws_s3_bucket.default[0].arn,
          "${aws_s3_bucket.default[0].arn}/*"
        ]
        Condition = {
          Bool = {
            "aws:SecureTransport" = "false"
          }
        }
        Principal = "*"
      },
      {
        Sid    = "AllowBillingGetBucket"
        Effect = "Allow"
        Action = [
          "s3:GetBucketAcl",
          "s3:GetBucketPolicy"
        ]
        Resource = [
          aws_s3_bucket.default[0].arn
        ]
        Condition = {
          StringEquals = {
            "aws:SourceAccount" = local.account_id
            "aws:SourceArn"     = "arn:aws:cur:us-east-1:${local.account_id}:definition/*"
          }
        }
        Principal = {
          "Service" = "billingreports.amazonaws.com"
        }
      },
      {
        Sid    = "AllowBillingPutBucket"
        Effect = "Allow"
        Action = [
          "s3:PutObject"
        ]
        Resource = [
          "${aws_s3_bucket.default[0].arn}/*"
        ]
        Condition = {
          StringEquals = {
            "aws:SourceAccount" = local.account_id
            "aws:SourceArn"     = "arn:aws:cur:us-east-1:${local.account_id}:definition/*"
          }
        }
        Principal = {
          "Service" = "billingreports.amazonaws.com"
        }
      }
    ]
  })
}

#
# CUR
#
resource "aws_cur_report_definition" "default" {
  count = var.existing_cur_report_name == null ? 1 : 0

  provider = aws.us_east_1

  additional_schema_elements = ["RESOURCES"]
  compression                = "Parquet"
  format                     = "Parquet"
  refresh_closed_reports     = false
  report_name                = coalesce(var.existing_cur_report_name, "darktrace-cur")
  report_versioning          = "CREATE_NEW_REPORT"
  s3_bucket                  = coalesce(var.existing_cur_bucket_name, try(aws_s3_bucket.default[0].bucket, ""))
  s3_prefix                  = coalesce(var.existing_cur_bucket_prefix, "reports")
  s3_region                  = "us-east-1"
  time_unit                  = "DAILY"

  depends_on = [aws_s3_bucket_policy.default]
}
