resource "aws_iam_user" "clickhouse_backup" {
  name  = "${var.deployment_name}-clickhouse-backup"
}

resource "aws_iam_user_policy" "clickhouse_backup" {
  name   = "${var.deployment_name}-clickhouse-backup"
  user   = aws_iam_user.clickhouse_backup.name
  policy = data.aws_iam_policy_document.clickhouse_backup.json
}

data "aws_iam_policy_document" "clickhouse_backup" {
  statement {
    effect    = "Allow"
    actions   = ["s3:ListBucket"]
    resources = [aws_s3_bucket.clickhouse_backup.arn]
  }

  statement {
    effect = "Allow"
    actions = [
      "s3:PutObject",
      "s3:GetObject",
      "s3:ListBucket",
      "s3:DeleteObject"
    ]
    resources = [
      "${aws_s3_bucket.clickhouse_backup.arn}/*"
    ]
  }
}

resource "aws_iam_access_key" "clickhouse_backup" {
  user  = aws_iam_user.clickhouse_backup.name
}
