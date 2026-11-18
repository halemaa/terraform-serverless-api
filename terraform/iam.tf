# iam.tf
# IAM = Identity and Access Management = "who is allowed to do what."
#
# This is the MOST important file for security. The golden rule is
# LEAST PRIVILEGE: give the Lambda the smallest set of permissions it needs
# to do its job, and nothing more. If the code is ever compromised, the
# attacker inherits only these tiny permissions.

# ---- 1. A role the Lambda is allowed to "wear" while it runs ----
# The assume_role_policy says: "the Lambda service is allowed to use this role."
data "aws_iam_policy_document" "lambda_assume" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "lambda" {
  name               = "${local.name_prefix}-lambda-role"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume.json
}

# ---- 2. Permission to write its own logs ----
# Lambda needs to create log streams in CloudWatch. This is scoped to only
# this function's own log group, not every log group in the account.
data "aws_iam_policy_document" "lambda_logs" {
  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]
    resources = ["${aws_cloudwatch_log_group.lambda.arn}:*"]
  }
}

# ---- 3. Permission to touch ONLY our one DynamoDB table ----
# Notice: no "dynamodb:*". We list the exact actions, and the "resources"
# line points at our table's ARN and nothing else in the account.
data "aws_iam_policy_document" "lambda_dynamodb" {
  statement {
    effect = "Allow"
    actions = [
      "dynamodb:GetItem",
      "dynamodb:PutItem",
      "dynamodb:DeleteItem",
      "dynamodb:Scan",
    ]
    resources = [aws_dynamodb_table.items.arn]
  }
}

resource "aws_iam_role_policy" "lambda_logs" {
  name   = "${local.name_prefix}-logs"
  role   = aws_iam_role.lambda.id
  policy = data.aws_iam_policy_document.lambda_logs.json
}

resource "aws_iam_role_policy" "lambda_dynamodb" {
  name   = "${local.name_prefix}-dynamodb"
  role   = aws_iam_role.lambda.id
  policy = data.aws_iam_policy_document.lambda_dynamodb.json
}
