resource "aws_s3_bucket" "default" {
  count  = local.dt_managed && var.setup_cloudtrail ? 1 : 0
  bucket = "darktrace-bucket-${local.account_id}"

  tags          = var.darktrace_cloud_security_tags
  force_destroy = true
}

resource "aws_s3_bucket_versioning" "default" {
  count  = local.dt_managed && var.setup_cloudtrail ? 1 : 0
  bucket = aws_s3_bucket.default[0].id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "default" {
  count  = local.dt_managed && var.setup_cloudtrail ? 1 : 0
  bucket = aws_s3_bucket.default[0].id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "default" {
  count  = local.dt_managed && var.setup_cloudtrail ? 1 : 0
  bucket = aws_s3_bucket.default[0].id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_lifecycle_configuration" "default" {
  count  = local.dt_managed && var.setup_cloudtrail ? 1 : 0
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
  count  = local.dt_managed && var.setup_cloudtrail ? 1 : 0
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
