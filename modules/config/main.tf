data "aws_caller_identity" "current" {
}

#################
# S3 Bucket
#################
resource "aws_s3_bucket" "awsconfig" {
  bucket = "config-bucket-${data.aws_caller_identity.current.account_id}"
}

resource "aws_s3_bucket_ownership_controls" "awsconfig" {
  bucket = aws_s3_bucket.awsconfig.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "example" {
  depends_on = [aws_s3_bucket_ownership_controls.awsconfig]

  bucket = aws_s3_bucket.awsconfig.id
  acl    = "private"
}

data "aws_iam_policy_document" "s3bucket_policy-awsconfig" {
  version = "2012-10-17"
  statement {
    sid    = "AWSConfigBucketPermissionsCheck"
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["config.amazonaws.com"]
    }
    actions = [
      "s3:GetBucketAcl",
      "s3:ListBucket"
    ]
    resources = [
      "${aws_s3_bucket.awsconfig.arn}"
    ]
  }
  statement {
    sid    = "AWSConfigBucketDelivery"
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["config.amazonaws.com"]
    }
    actions = [
      "s3:PutObject"
    ]
    resources = [
      "${aws_s3_bucket.awsconfig.arn}/AWSLogs/${data.aws_caller_identity.current.account_id}/Config/*"
    ]
    condition {
      test     = "StringEquals"
      variable = "s3:x-amz-acl"
      values   = ["bucket-owner-full-control"]
    }
  }
}

resource "aws_s3_bucket_policy" "awsconfig" {
  bucket = aws_s3_bucket.awsconfig.bucket
  policy = data.aws_iam_policy_document.s3bucket_policy-awsconfig.json
}

#############
# IAM Role
#############
data "aws_iam_policy_document" "assume_role_policy-awsconfig" {
  version = "2012-10-17"
  statement {
    sid    = ""
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["config.amazonaws.com"]
    }
    actions = [
      "sts:AssumeRole"
    ]
  }
}

resource "aws_iam_role" "role_awsconfig" {
  name               = "AWSServiceRoleForConfig"
  path               = "/service-role/"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy-awsconfig.json
}

resource "aws_iam_role_policy_attachment" "awsconfig_AWSConfigRole" {
  role       = aws_iam_role.role_awsconfig.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSConfigRole"
}

#############
# Config
#############
resource "aws_config_configuration_recorder" "awsconfig" {
  name     = "awsconfig-${data.aws_caller_identity.current.account_id}"
  role_arn = aws_iam_role.role_awsconfig.arn
  recording_group {
    all_supported                 = "true"
    include_global_resource_types = "true"
  }
}
resource "aws_config_delivery_channel" "awsconfig" {
  name           = "awsconfig-${data.aws_caller_identity.current.account_id}"
  s3_bucket_name = aws_s3_bucket.awsconfig.bucket
  depends_on     = [aws_config_configuration_recorder.awsconfig]
}
