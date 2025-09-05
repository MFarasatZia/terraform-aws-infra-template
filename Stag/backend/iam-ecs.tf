#############################################
# ECS Execution Role (Concise & Safe)
# - Pulls from ECR, writes logs, etc.
# - Optional: read specific Secrets Manager / SSM params
#############################################

resource "aws_iam_role" "ecs_execution" {
  name = "${var.name_prefix}-${var.service_name}-exec"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect    = "Allow",
      Principal = { Service = "ecs-tasks.amazonaws.com" },
      Action    = "sts:AssumeRole"
    }]
  })
}

# Best practice: attach AWS-managed execution policy (ECR auth + logs, etc.)
resource "aws_iam_role_policy_attachment" "ecs_execution_managed" {
  role       = aws_iam_role.ecs_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# Optional, least-privilege access to specific secrets/params your container needs
data "aws_iam_policy_document" "ecs_execution_extras" {
  statement {
    sid     = "ReadSpecificSecretsManager"
    effect  = "Allow"
    actions = ["secretsmanager:GetSecretValue", "secretsmanager:DescribeSecret"]
    resources = var.secrets_manager_secret_arns
  }

  statement {
    sid     = "ReadSpecificSSMParameters"
    effect  = "Allow"
    actions = ["ssm:GetParameter", "ssm:GetParameters", "ssm:GetParametersByPath"]
    resources = var.ssm_parameter_arns
  }
}

resource "aws_iam_role_policy" "ecs_execution_extras" {
  count  = (length(var.secrets_manager_secret_arns) + length(var.ssm_parameter_arns)) > 0 ? 1 : 0
  name   = "${var.name_prefix}-${var.service_name}-exec-extras"
  role   = aws_iam_role.ecs_execution.id
  policy = data.aws_iam_policy_document.ecs_execution_extras.json
}

#############################################
# ECS Task Role (your app’s runtime perms)
# - Example: allow invoking specific Lambdas
#############################################

resource "aws_iam_role" "ecs_task" {
  name = "${var.name_prefix}-${var.service_name}-task"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect    = "Allow",
      Principal = { Service = "ecs-tasks.amazonaws.com" },
      Action    = "sts:AssumeRole"
    }]
  })
}

data "aws_iam_policy_document" "ecs_task_inline" {
  statement {
    sid     = "InvokeSpecificLambdas"
    effect  = "Allow"
    actions = ["lambda:InvokeFunction"]
    resources = var.lambda_invoke_arns
  }
}

resource "aws_iam_role_policy" "ecs_task_inline" {
  count  = length(var.lambda_invoke_arns) > 0 ? 1 : 0
  name   = "${var.name_prefix}-${var.service_name}-task-inline"
  role   = aws_iam_role.ecs_task.id
  policy = data.aws_iam_policy_document.ecs_task_inline.json
}
