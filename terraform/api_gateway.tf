# api_gateway.tf
# The "front desk" — a public HTTP API that forwards requests to the Lambda.
# We use the HTTP API (apigatewayv2), which is cheaper and simpler than the
# older REST API, and ideal for a Lambda backend.

resource "aws_apigatewayv2_api" "http" {
  name          = "${local.name_prefix}-http"
  protocol_type = "HTTP"

  # Basic CORS so a browser front-end could call this API later.
  cors_configuration {
    allow_origins = ["*"]
    allow_methods = ["GET", "POST", "DELETE", "OPTIONS"]
    allow_headers = ["content-type"]
  }
}

# The "integration" is the wire between the front desk and the driver.
resource "aws_apigatewayv2_integration" "lambda" {
  api_id                 = aws_apigatewayv2_api.http.id
  integration_type       = "AWS_PROXY"
  integration_uri        = aws_lambda_function.api.invoke_arn
  payload_format_version = "2.0"
}

# Routes map a URL + method to the integration.
# One Lambda handles all of them and decides what to do based on the path.
locals {
  routes = [
    "GET /items",
    "POST /items",
    "GET /items/{id}",
    "DELETE /items/{id}",
    "GET /health",
  ]
}

resource "aws_apigatewayv2_route" "routes" {
  for_each  = toset(local.routes)
  api_id    = aws_apigatewayv2_api.http.id
  route_key = each.value
  target    = "integrations/${aws_apigatewayv2_integration.lambda.id}"
}

# A "stage" is a deployed, callable version of the API. auto_deploy keeps it
# in sync with changes. "$default" means the URL has no extra path prefix.
resource "aws_apigatewayv2_stage" "default" {
  api_id      = aws_apigatewayv2_api.http.id
  name        = "$default"
  auto_deploy = true

  # Log every request — useful for debugging and security review.
  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.api.arn
    format = jsonencode({
      requestId    = "$context.requestId"
      ip           = "$context.identity.sourceIp"
      method       = "$context.httpMethod"
      route        = "$context.routeKey"
      status       = "$context.status"
      responseTime = "$context.responseLatency"
    })
  }
}

resource "aws_cloudwatch_log_group" "api" {
  name              = "/aws/apigateway/${local.name_prefix}"
  retention_in_days = var.log_retention_days
}

# Finally: allow API Gateway to invoke the Lambda. Without this explicit
# permission, the front desk is not allowed to call the driver.
resource "aws_lambda_permission" "api_gw" {
  statement_id  = "AllowInvokeFromHttpApi"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.api.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.http.execution_arn}/*/*"
}
