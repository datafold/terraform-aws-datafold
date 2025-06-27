# ╻ ╻┏━┓┏━╸   ┏━╸╻  ┏━┓╻ ╻   ╻  ┏━┓┏━╸┏━┓
# ┃┏┛┣━┛┃     ┣╸ ┃  ┃ ┃┃╻┃   ┃  ┃ ┃┃╺┓┗━┓
# ┗┛ ╹  ┗━╸   ╹  ┗━╸┗━┛┗┻┛   ┗━╸┗━┛┗━┛┗━┛

resource "aws_iam_role" "vpc_flow_logs" {
  count = var.deploy_vpc_flow_logs ? 1 : 0
  name  = "${var.deployment_name}-vpc-flow-logs-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "vpc-flow-logs.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "vpc_flow_logs" {
  count = var.deploy_vpc_flow_logs ? 1 : 0
  name  = "${var.deployment_name}-vpc-flow-logs-role-policy"
  role  = one(aws_iam_role.vpc_flow_logs[*].id)

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "logs:DescribeLogGroups",
        "logs:DescribeLogStreams"
      ],
      "Effect": "Allow",
      "Resource": "${one(aws_cloudwatch_log_group.vpc_flow_logs[*].arn)}:*"
    }
  ]
}
EOF
}
