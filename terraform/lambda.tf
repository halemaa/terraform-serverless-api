# lambda.tf
# The "taxi driver" — our code, packaged and uploaded as a Lambda function.

# Turn the src/ folder into a .zip that Lambda can run.
# Terraform does this for us at plan/apply time; no manual zipping.
data "archive_file" "lambda" {
  type        = "zip"
  source_dir  = "${path.module}/../src"
  output_path = "${path.module}/build/lambda.zip"
}

# A dedicated log group, so we control retention (and therefore cost).
resource "aws_cloudwatch_log_group" "lambda" {
  name              = "/aws/lambda/${local.name_prefix}"
  retention_in_days = var.log_retention_days
}

resource "aws_lambda_function" "api" {
  function_name = local.name_prefix
  role          = aws_iam_role.lambda.arn

  runtime = "python3.12"
  handler = "handler.handler" # file "handler.py", function "handler"

  filename         = data.archive_file.lambda.output_path
  source_code_hash = data.archive_file.lambda.output_base64sha256 # redeploy only when code changes

  memory_size = 128 # smallest size — plenty for this; keeps cost minimal
  timeout     = 10  # seconds

  environment {
    variables = {
      TABLE_NAME = aws_dynamodb_table.items.name
    }
  }

  # Don't create the function until its log group and permissions exist.
  depends_on = [
    aws_iam_role_policy.lambda_logs,
    aws_cloudwatch_log_group.lambda,
  ]
}
