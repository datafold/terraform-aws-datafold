# AWS Lambda in VPC with API Gateway and Least Privilege Access

To facilitate an internal load balancer, GitHub webhooks still need to have a way to reach the application. This is achieved by creating a reverse proxy for GitHub webhooks. This Terraform module deploys an AWS Lambda function inside a VPC, integrates it with API Gateway, and ensures least privilege access. The Lambda function receives webhooks from GitHub, processes them, and forwards them to a private system inside a VPC.

The module includes:
- A Lambda function attached to a VPC.
- Integration with API Gateway to expose the Lambda function as an HTTP endpoint.
- A deny policy to follow the principle of least privilege, preventing the Lambda function code from making certain Amazon EC2 API calls.
- Required IAM roles and permissions for VPC access and logging.
- A Security Group to allow access to the private endpoint in the VPC.

## Features
- Deploys an AWS Lambda function inside a VPC.
- Integrates the Lambda function with API Gateway for receiving webhooks.
- Configures the necessary IAM roles, including the `AWSLambdaVPCAccessExecutionRole`.
- Implements a custom deny policy to prevent the Lambda function from making EC2 network-related API calls.
- CloudWatch logging for monitoring and troubleshooting.

## Usage

```hcl
module "lambda_vpc_webhook" {
  source = "./path_to_your_module" # Replace with your module path

  # Variables
  vpc_id                   = "vpc-12345678"
  vpc_private_subnets      = ["subnet-abcdefgh", "subnet-ijklmnop"]
  github_secret            = "your-github-webhook-secret"
  private_system_endpoint  = "the ip of the internal load balancer"
}

output "api_gateway_url" {
  value = module.lambda_vpc_webhook.api_gateway_url
}
```
