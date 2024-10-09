resource "null_resource" "zip_lambda_function" {
  provisioner "local-exec" {
    command = "zip -j lambda_function.zip lambda_function.py"
  }

  triggers = {
    py_source = filemd5("lambda_function.py")
  }
}

resource "aws_lambda_function" "github_webhook_handler" {
  function_name = "${var.deployment_name}-github-webhook-handler"
  role          = aws_iam_role.lambda_role.arn
  handler       = "lambda_function.lambda_handler" # Python handler
  runtime       = "python3.12"

  filename         = "${path.module}/lambda_function.zip"
  source_code_hash = filebase64sha256("${path.module}/lambda_function.zip")

  environment {
    variables = {
      GITHUB_SECRET           = var.github_secret
      PRIVATE_SYSTEM_ENDPOINT = var.private_system_endpoint
    }
  }

  vpc_config {
    subnet_ids         = var.vpc_private_subnets
    security_group_ids = length(var.security_group_ids) > 0 ? var.security_group_ids : [aws_security_group.lambda_sg.id]
  }

  # Depend on the zip operation
  depends_on = [null_resource.zip_lambda_function]
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
  uri                     = aws_lambda_function.github_webhook_handler.invoke_arn
}

# Deployment of API Gateway
resource "aws_api_gateway_deployment" "api_deployment" {
  rest_api_id = aws_api_gateway_rest_api.webhook_api.id
  stage_name  = "prod"

  depends_on = [aws_api_gateway_integration.lambda_integration]
}