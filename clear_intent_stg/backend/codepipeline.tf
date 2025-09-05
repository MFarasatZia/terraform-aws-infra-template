#############################################
# CodeStar Connection (GitHub)
#############################################

resource "aws_codestarconnections_connection" "github" {
  name          = "${var.name_prefix}-github"
  provider_type = "GitHub"
}

#############################################
# CodePipeline: Source → Build(CodeBuild) → Deploy(CodeDeploy to ECS)
#############################################

resource "aws_codepipeline" "app" {
  name     = "${var.name_prefix}-docker-pipeline"
  role_arn = var.codepipeline_role_arn

  artifact_store {
    location = var.artifact_bucket
    type     = "S3"

    dynamic "encryption_key" {
      for_each = var.kms_artifacts_key_arn == "" ? [] : [1]
      content {
        id   = var.kms_artifacts_key_arn
        type = "KMS"
      }
    }
  }

  # ── Stage 1: Source (GitHub via CodeStar Connection)
  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeStarSourceConnection"
      version          = "1"
      output_artifacts = ["${var.name_prefix}-docker-source"]

      configuration = {
        ConnectionArn    = aws_codestarconnections_connection.github.arn
        FullRepositoryId = "${var.repo_owner}/${var.repo_name}"   # e.g., org/repo
        BranchName       = var.branch
      }
    }
  }

  # ── Stage 2: Build (CodeBuild)
  stage {
    name = "Build"

    action {
      name             = "Build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      version          = "1"
      input_artifacts  = ["${var.name_prefix}-docker-source"]
      output_artifacts = ["${var.name_prefix}-docker-build"]

      configuration = {
        ProjectName = var.codebuild_project_name   # e.g., aws_codebuild_project.app.name
      }
    }
  }

  # ── Stage 3: Deploy (CodeDeploy to ECS Blue/Green)
  stage {
    name = "DeployApplication"

    action {
      name            = "DeployToECS"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "CodeDeployToECS"
      version         = "1"
      input_artifacts = ["${var.name_prefix}-docker-build"]

      configuration = {
        ApplicationName                = var.codedeploy_app_name                  # e.g., aws_codedeploy_app.ecs.name
        DeploymentGroupName            = var.codedeploy_deployment_group_name     # e.g., aws_codedeploy_deployment_group.ecs.deployment_group_name
        TaskDefinitionTemplateArtifact = "${var.name_prefix}-docker-build"
        AppSpecTemplateArtifact        = "${var.name_prefix}-docker-build"
      }
    }
  }
}
