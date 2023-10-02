data "aws_caller_identity" "current" {
}

########################
# Account Password Policy
########################
resource "aws_iam_account_password_policy" "strict" {
  minimum_password_length        = 14
  require_lowercase_characters   = true
  require_numbers                = true
  require_uppercase_characters   = true
  require_symbols                = true
  allow_users_to_change_password = true
  password_reuse_prevention      = 24
}

########################
# Support Access Role
########################
resource "aws_iam_role" "support_access" {
  name                 = "AWSSupportAccessRole"
  max_session_duration = 3600
  path                 = "/"
  assume_role_policy = jsonencode(
    {
      Statement = [
        {
          Action    = "sts:AssumeRole"
          Condition = {}
          Effect    = "Allow"
          Principal = {
            AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
          }
        },
      ]
      Version = "2012-10-17"
    }
  )
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/AWSSupportAccess",
  ]
}
