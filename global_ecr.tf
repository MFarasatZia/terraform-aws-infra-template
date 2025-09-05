resource "aws_ecr_repository" "python_repo" {
  name         = "python"
  force_delete = true

  provisioner "local-exec" {
    command = "./scripts/setup-docker.sh"
    environment = {
      REPO               = "python"
      TAG                = "3.8.3-alpine"
      AWS_ACCOUNT_ID     = data.aws_caller_identity.current.account_id
      AWS_DEFAULT_REGION = var.AWS_REGION
      PROFILE            = "default" # sanitized AWS CLI profile
    }
  }
}

resource "aws_ecr_repository" "postgres_repo" {
  name         = "postgres"
  force_delete = true

  provisioner "local-exec" {
    command = "./scripts/setup-docker.sh"
    environment = {
      REPO               = "postgres"
      TAG                = "12"
      AWS_ACCOUNT_ID     = data.aws_caller_identity.current.account_id
      AWS_DEFAULT_REGION = var.AWS_REGION
      PROFILE            = "default" # sanitized AWS CLI profile
    }
  }
}
