// Definition of IAM role
resource "aws_iam_role" "iam_for_lambda" {
    name = "${var.team}-${var.name}"
    assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
    {
        "Action": "sts:AssumeRole",
        "Principal": {
            "Service": "lambda.amazonaws.com"
        },
        "Effect": "Allow",
        "Sid": ""
    }
    ]
}
    EOF
    tags = {
        Team          = "${var.team}"
        Product       = "${var.product}"
        Department    = "${var.department}"
        Environment   = "${var.environment}"
    }
}

// Definition of Cloudwatch log group
resource "aws_cloudwatch_log_group" "retention" {
    name              = "/aws/lambda/${var.team}-${var.name}"
    retention_in_days = var.retention_in_days
}

// Definition of IAM policy
resource "aws_iam_policy" "lambda_logging" {
    name        = "${var.team}-${var.name}-lambda_logging"
    path        = "/"
    description = "IAM policy for logging from a lambda"
    policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "*",
      "Effect": "Allow"
    }
  ]
}
    EOF
    tags = {
        Team          = "${var.team}"
        Product       = "${var.product}"
        Department    = "${var.department}"
        Environment   = "${var.environment}"
    }
}

// Attach policy to role
resource "aws_iam_role_policy_attachment" "lambda_logs" {
    role       = aws_iam_role.iam_for_lambda.name
    policy_arn = aws_iam_policy.lambda_logging.arn
}

// Definition of IAM policy
resource "aws_iam_policy" "lambda_specific" {
    name        = "${var.team}-${var.name}-lambda_specific"
    path        = "/"
    description = "IAM policy specific for the application"
    policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "rds:DownloadDBLogFilePortion",
        "rds:DownloadCompleteDBLogFile",
        "s3:PutObject",
        "s3:GetObjectAcl",
        "s3:GetObject",
        "s3:DeleteObject",
        "s3:PutObjectAcl",
        "s3:ListBucket",
        "s3:ListAllMyBuckets"
      ],
      "Resource": "*",
      "Effect": "Allow"
    }
  ]
}
    EOF
    tags = {
        Team          = "${var.team}"
        Product       = "${var.product}"
        Department    = "${var.department}"
        Environment   = "${var.environment}"
    }
}

// Attach policy to role
resource "aws_iam_role_policy_attachment" "lambda_spec" {
    role       = aws_iam_role.iam_for_lambda.name
    policy_arn = aws_iam_policy.lambda_specific.arn
}