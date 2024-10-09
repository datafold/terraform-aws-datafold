# AWS Lambda in VPC with API Gateway and Least Privilege Access

To facilitate an internal load balancer, GitHub webhooks still need to have a way to reach the application. This is achieved by creating a reverse proxy for GitHub webhooks. This Terraform module deploys an AWS Lambda function inside a VPC, integrates it with API Gateway, and ensures least privilege access. The Lambda function receives webhooks from GitHub, processes them, and forwards them to a private system inside a VPC.

## Features
- Deploys an AWS Lambda function inside a VPC.
- Integrates the Lambda function with API Gateway for receiving webhooks.
- Limits access to the API Gateway only to request from GitHub CIDR ranges.
- Configures the necessary IAM roles, including the `AWSLambdaVPCAccessExecutionRole`.
- Implements a custom deny policy to prevent the Lambda function from making EC2 network-related API calls.
- DataDog Lambda extension for logging and monitoring.
