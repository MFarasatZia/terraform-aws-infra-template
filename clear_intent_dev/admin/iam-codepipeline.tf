#############################################
# CodePipeline IAM Role (Concise & Safe)
#############################################

resource "aws_iam_role" "codepipeline" {
  name = "${var.name_prefix}-codepipeline"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect    = "Allow",
      Principal = { Service = "codepipeline.amazonaws.com" },
      Action    = "sts:AssumeRole"
    }]
  })
}

# Inline policy: S3 artifacts (+optional KMS), CodeBuild, CodeDeploy/ECS, CodeStar Connections, PassRole to ECS task roles
data "aws_iam_policy_document" "codepipeline" {
  # S3 artifacts bucket (rw)
  statement {
    effect = "Allow"
    actions = [
      "s3:PutObject", "s3:GetObject", "s3:GetObjectVersion",
      "s3:GetBucketVersioning", "s3:ListBucket"
    ]
    resources = [
      var.artifact_bucket_arn,
      "${var.artifact_bucket_arn}/*"
    ]
  }

  # Optional KMS for artifact encryption
  statement {
    effect = "Allow"
    actions = [
      "kms:DescribeKey", "kms:Decrypt",
      "kms:Encrypt", "kms:ReEncrypt*", "kms:GenerateDataKey*"
    ]
    resources = var.kms_artifacts_key_arn == "" ? [] : [var.kms_artifacts_key_arn]
  }

  # CodeBuild (start & read builds) for build stage
  statement {
    effect = "Allow"
    actions = ["codebuild:StartBuild", "codebuild:BatchGetBuilds"]
    resources = var.codebuild_project_arns
  }

  # CodeDeploy to ECS (deploy stage) - minimal set commonly needed by the action
  statement {
    effect = "Allow"
    actions = [
      "codedeploy:CreateDeployment",
      "codedeploy:Get*",
      "codedeploy:List*"
    ]
    resources = [
      var.codedeploy_app_arn,
      var.codedeploy_deployment_group_arn
    ]
  }

  # ECS (read-only; deploy action operates via CodeDeploy)
  statement {
    effect = "Allow"
    actions = ["ecs:DescribeServices", "ecs:DescribeTaskDefinition", "ecs:DescribeTaskSets", "ecs:List*"]
    resources = ["*"]
  }

  # Use the CodeStar Connection for GitHub source
  statement {
    effect = "Allow"
    actions = ["codestar-connections:UseConnection"]
    resources = [var.codestar_connection_arn]
  }

  # Pass roles to ECS tasks (so deployments can use your task/execution roles)
  statement {
    effect = "Allow"
    actions = ["iam:PassRole"]
    resources = concat(var.ecs_execution_role_arns, var.ecs_task_role_arns)
    condition {
      test     = "StringLike"
      variable = "iam:PassedToService"
      values   = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy" "codepipeline" {
  name   = "${var.name_prefix}-codepipeline-inline"
  role   = aws_iam_role.codepipeline.id
  policy = data.aws_iam_policy_document.codepipeline.json
}
