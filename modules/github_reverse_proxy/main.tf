data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

data "archive_file" "zip_lambda_function" {
  type        = "zip"
  source_file = "${path.module}/lambda_function.py"
  output_path = "${path.module}/lambda_function.zip"
}

resource "aws_secretsmanager_secret" "datadog_api_key" {
  name        = "datadog_api_key"
  description = "Datadog API Key used for monitoring Lambda"
}

resource "aws_secretsmanager_secret_version" "datadog_api_key_version" {
  secret_id     = aws_secretsmanager_secret.datadog_api_key.id
  secret_string = var.datadog_api_key # This should be the Datadog API key (input as a variable)
}

locals {
  function_name = "${var.deployment_name}-github-webhook-handler"
  role          = aws_iam_role.lambda_role.arn
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.12"
  memory_size   = 256
  timeout       = 120
  publish       = true

  filename         = data.archive_file.zip_lambda_function.output_path
  source_code_hash = data.archive_file.zip_lambda_function.output_base64sha256

  private_system_endpoint = "https://${var.private_system_endpoint}/integrations/github/v1/app_hook"

  subnet_ids         = var.vpc_private_subnets
  security_group_ids = length(var.security_group_ids) > 0 ? var.security_group_ids : [aws_security_group.lambda_sg.id]
}

module "lambda_datadog" {
  count = var.monitor_lambda_datadog ? 1 : 0

  source  = "DataDog/lambda-datadog/aws"
  version = "1.4.0"

  function_name = local.function_name
  role          = local.role
  handler       = local.handler
  runtime       = local.runtime
  memory_size   = local.memory_size
  timeout       = local.timeout
  publish       = local.publish

  filename         = local.filename
  source_code_hash = local.source_code_hash

  environment_variables = {
    "DD_API_KEY_SECRET_ARN" : aws_secretsmanager_secret.datadog_api_key.arn
    "DD_ENV" : var.environment
    "DD_SERVICE" : "github-webhook-service"
    "DD_SITE" : "datadoghq.com"
    "DD_VERSION" : "1.0.0"
    "DD_EXTENSION_VERSION" : "next"
    "DD_SERVERLESS_LOGS_ENABLED" : "true"
    "DD_LOG_LEVEL" : "INFO"
    "DD_TAGS" : "deployment:${var.deployment_name}"
    "PRIVATE_SYSTEM_ENDPOINT" : local.private_system_endpoint
    "DATADOG_MONITORING_ENABLED" : "false",
    "DD_TRACE_ENABLED" : "false",
  }

  vpc_config_subnet_ids         = local.subnet_ids
  vpc_config_security_group_ids = local.security_group_ids

  datadog_extension_layer_version = 63
  datadog_python_layer_version    = 98

  # Depend on the zip operation
  depends_on = [data.archive_file.zip_lambda_function]
}

resource "aws_lambda_function" "github_webhook_handler" {
  count = var.monitor_lambda_datadog ? 0 : 1

  function_name = local.function_name
  role          = local.role
  handler       = local.handler
  runtime       = local.runtime
  memory_size   = local.memory_size
  timeout       = local.timeout
  publish       = local.publish

  filename         = local.filename
  source_code_hash = local.source_code_hash

  environment {
    variables = {
      PRIVATE_SYSTEM_ENDPOINT = local.private_system_endpoint
    }
  }

  vpc_config {
    subnet_ids         = local.subnet_ids
    security_group_ids = local.security_group_ids
  }

  # Depend on the zip operation
  depends_on = [data.archive_file.zip_lambda_function]
}

locals {
  function_version = coalesce(concat(module.lambda_datadog[*].version, aws_lambda_function.github_webhook_handler[*].version)...)
}

resource "aws_lambda_alias" "prod_alias" {
  name             = "prod"
  function_name    = local.function_name
  function_version = local.function_version
}

resource "aws_lambda_provisioned_concurrency_config" "example" {
  function_name                     = aws_lambda_alias.prod_alias.function_name
  provisioned_concurrent_executions = 1
  qualifier                         = aws_lambda_alias.prod_alias.name
}

resource "aws_lambda_function_event_invoke_config" "concurrency_limit" {
  function_name          = aws_lambda_alias.prod_alias.function_name
  qualifier              = aws_lambda_alias.prod_alias.name
  maximum_retry_attempts = 2
}

resource "aws_lambda_permission" "lambda_permission" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_alias.prod_alias.function_name
  qualifier     = aws_lambda_alias.prod_alias.name
  principal     = "apigateway.amazonaws.com"

  # The /* part allows invocation from any stage, method and resource path
  # within API Gateway.
  source_arn = "${aws_api_gateway_rest_api.webhook_api.execution_arn}/*"
}

# API Gateway to act as a reverse proxy
resource "aws_api_gateway_rest_api" "webhook_api" {
  name = "GitHub Webhook Reverse Proxy"
}

# Create resource for webhooks
resource "aws_api_gateway_resource" "webhook_resource" {
  rest_api_id = aws_api_gateway_rest_api.webhook_api.id
  parent_id   = aws_api_gateway_rest_api.webhook_api.root_resource_id
  path_part   = "webhook"
}

# API Gateway Method
resource "aws_api_gateway_method" "post_webhook" {
  rest_api_id   = aws_api_gateway_rest_api.webhook_api.id
  resource_id   = aws_api_gateway_resource.webhook_resource.id
  http_method   = "POST"
  authorization = "NONE"
}

# Lambda integration for API Gateway
resource "aws_api_gateway_integration" "lambda_integration" {
  rest_api_id             = aws_api_gateway_rest_api.webhook_api.id
  resource_id             = aws_api_gateway_resource.webhook_resource.id
  http_method             = aws_api_gateway_method.post_webhook.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_alias.prod_alias.invoke_arn
}

# Deployment of API Gateway
resource "aws_api_gateway_deployment" "api_deployment" {
  rest_api_id = aws_api_gateway_rest_api.webhook_api.id

  depends_on = [aws_api_gateway_integration.lambda_integration]
}

resource "aws_api_gateway_stage" "stage" {
  deployment_id = aws_api_gateway_deployment.api_deployment.id
  rest_api_id   = aws_api_gateway_rest_api.webhook_api.id
  stage_name    = "prod"
}

resource "aws_api_gateway_rest_api_policy" "github_ip_restriction" {
  rest_api_id = aws_api_gateway_rest_api.webhook_api.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect : "Allow",
        Principal : "*",
        Action : "execute-api:Invoke",
        Resource : "arn:aws:execute-api:${data.aws_region.current.region}:${data.aws_caller_identity.current.account_id}:${aws_api_gateway_rest_api.webhook_api.id}/*/POST/*",
      },
      {
        Effect : "Deny",
        Principal : "*",
        Action : "execute-api:Invoke",
        Resource : "arn:aws:execute-api:${data.aws_region.current.region}:${data.aws_caller_identity.current.account_id}:${aws_api_gateway_rest_api.webhook_api.id}/*/POST/*",
        Condition : {
          "NotIpAddress" : {
            "aws:SourceIp" : var.github_cidrs
          }
        }
      }
    ]
  })
}
