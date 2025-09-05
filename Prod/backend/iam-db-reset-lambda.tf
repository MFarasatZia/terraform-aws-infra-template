#############################################
# Lambda IAM Role (DB reset) — Concise & Safe
#############################################

resource "aws_iam_role" "db_reset_lambda" {
  name = "${var.name_prefix}-db-reset-lambda"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect    = "Allow",
      Principal = { Service = "lambda.amazonaws.com" },
      Action    = "sts:AssumeRole"
    }]
  })
}

# Basic logging to CloudWatch
resource "aws_iam_role_policy_attachment" "db_reset_lambda_basic" {
  role       = aws_iam_role.db_reset_lambda.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# If your Lambda runs in a VPC, attach VPC access permissions (creates/attaches ENIs)
resource "aws_iam_role_policy_attachment" "db_reset_lambda_vpc" {
  role       = aws_iam_role.db_reset_lambda.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}
