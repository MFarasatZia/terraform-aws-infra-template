#############################################
# CodeDeploy IAM Role (ECS Blue/Green) — Safe
#############################################

resource "aws_iam_role" "codedeploy" {
  name = "${var.name_prefix}-codedeploy"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect    = "Allow",
      Principal = { Service = "codedeploy.amazonaws.com" },
      Action    = "sts:AssumeRole"
    }]
  })
}

# Inline policy for ECS blue/green via ALB + optional S3/KMS + PassRole
data "aws_iam_policy_document" "codedeploy" {
  # ECS + ALB control plane for blue/green
  statement {
    effect = "Allow"
    actions = [
      "ecs:DescribeServices",
      "ecs:CreateTaskSet",
      "ecs:UpdateServicePrimaryTaskSet",
      "ecs:DeleteTaskSet",
      "elasticloadbalancing:DescribeTargetGroups",
      "elasticloadbalancing:DescribeListeners",
      "elasticloadbalancing:ModifyListener",
      "elasticloadbalancing:DescribeRules",
      "elasticloadbalancing:ModifyRule",
      "cloudwatch:DescribeAlarms",
      "sns:Publish",
      "lambda:InvokeFunction"
    ]
    resources = ["*"]
  }

  # Read AppSpec/TaskDef from artifacts bucket (scoped)
  statement {
    effect = "Allow"
    actions = ["s3:GetObject", "s3:GetObjectVersion"]
    resources = ["${var.artifact_bucket_arn}/*"]
  }

  # Optional: if the artifacts are KMS-encrypted
  statement {
    effect = "Allow"
    actions = ["kms:DescribeKey", "kms:Decrypt"]
    resources = var.kms_artifacts_key_arn == "" ? [] : [var.kms_artifacts_key_arn]
  }

  # Pass roles to ECS tasks (execution + task role)
  statement {
    effect = "Allow"
    actions = ["iam:PassRole"]
    resources = concat(
      var.ecs_execution_role_arns,
      var.ecs_task_role_arns
    )
    condition {
      test     = "StringLike"
      variable = "iam:PassedToService"
      values   = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy" "codedeploy" {
  name   = "${var.name_prefix}-codedeploy-inline"
  role   = aws_iam_role.codedeploy.id
  policy = data.aws_iam_policy_document.codedeploy.json
}
