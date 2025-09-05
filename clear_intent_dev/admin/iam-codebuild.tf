#############################################
# CodeBuild IAM Role (Concise & Safe)
#############################################

resource "aws_iam_role" "codebuild" {
  name = "${var.name_prefix}-codebuild"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect    = "Allow",
      Principal = { Service = "codebuild.amazonaws.com" },
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy" "codebuild" {
  name = "${var.name_prefix}-codebuild-inline"
  role = aws_iam_role.codebuild.name

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      # CloudWatch Logs
      {
        Effect = "Allow",
        Action = ["logs:CreateLogGroup","logs:CreateLogStream","logs:PutLogEvents"],
        Resource = "*"
      },

      # VPC networking (only used if project is VPC-enabled)
      {
        Effect = "Allow",
        Action = [
          "ec2:CreateNetworkInterface","ec2:DeleteNetworkInterface","ec2:DescribeNetworkInterfaces",
          "ec2:DescribeVpcs","ec2:DescribeSubnets","ec2:DescribeSecurityGroups","ec2:DescribeDhcpOptions"
        ],
        Resource = "*"
      },

      # S3 cache bucket (rw)
      {
        Effect = "Allow",
        Action = ["s3:ListBucket"],
        Resource = [var.cache_bucket_arn]
      },
      {
        Effect = "Allow",
        Action = ["s3:GetObject","s3:PutObject","s3:DeleteObject"],
        Resource = ["${var.cache_bucket_arn}/*"]
      },

      # S3 artifacts bucket (rw)
      {
        Effect = "Allow",
        Action = ["s3:ListBucket"],
        Resource = [var.artifact_bucket_arn]
      },
      {
        Effect = "Allow",
        Action = ["s3:GetObject","s3:PutObject","s3:DeleteObject"],
        Resource = ["${var.artifact_bucket_arn}/*"]
      },

      # (Optional) S3 report bucket (rw) — omit if not used
      {
        Effect = "Allow",
        Action = ["s3:ListBucket"],
        Resource = var.report_bucket_arn == "" ? [] : [var.report_bucket_arn]
      },
      {
        Effect = "Allow",
        Action = ["s3:GetObject","s3:PutObject","s3:DeleteObject"],
        Resource = var.report_bucket_arn == "" ? [] : ["${var.report_bucket_arn}/*"]
      },

      # ECR push/pull to specific repos (use ARNs). Auth token is account-wide (*).
      {
        Sid    = "ECRAuth",
        Effect = "Allow",
        Action = ["ecr:GetAuthorizationToken"],
        Resource = "*"
      },
      {
        Sid    = "ECRRepoAccess",
        Effect = "Allow",
        Action = [
          "ecr:BatchCheckLayerAvailability","ecr:GetDownloadUrlForLayer","ecr:BatchGetImage",
          "ecr:DescribeRepositories","ecr:ListImages","ecr:DescribeImages","ecr:GetRepositoryPolicy",
          "ecr:InitiateLayerUpload","ecr:UploadLayerPart","ecr:CompleteLayerUpload","ecr:PutImage"
        ],
        Resource = var.ecr_repository_arns
      },

      # (Optional) ECS read-only (handy for post-build scripts)
      {
        Sid    = "ECSReadOnly",
        Effect = "Allow",
        Action = ["ecs:List*","ecs:Describe*"],
        Resource = "*"
      },

      # KMS for artifact encryption (optional)
      {
        Effect = "Allow",
        Action = ["kms:DescribeKey","kms:GenerateDataKey*","kms:Encrypt","kms:ReEncrypt*","kms:Decrypt"],
        Resource = var.kms_artifacts_key_arn == "" ? [] : [var.kms_artifacts_key_arn]
      },

      # Secrets Manager for build env secrets (optional)
      {
        Effect = "Allow",
        Action = ["secretsmanager:GetSecretValue","secretsmanager:DescribeSecret"],
        Resource = var.secrets_manager_arns
      }
    ]
  })
}
