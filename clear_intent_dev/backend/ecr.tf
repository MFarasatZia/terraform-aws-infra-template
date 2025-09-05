#############################################
# ECR Repository + Lifecycle Policy 
#############################################

resource "aws_ecr_repository" "app" {
  name = var.ecr_repo_name

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name = var.ecr_repo_name
  }
}

resource "aws_ecr_lifecycle_policy" "app" {
  repository = aws_ecr_repository.app.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Expire untagged images older than 1 day"
        selection = {
          tagStatus   = "untagged"
          countType   = "sinceImagePushed"
          countUnit   = "days"
          countNumber = 1
        }
        action = { type = "expire" }
      },
      {
        rulePriority = 2
        description  = "Expire date-tagged images older than 30 days"
        selection = {
          tagStatus     = "tagged"
          tagPrefixList = ["2025-"] # adjust to your tagging convention
          countType     = "sinceImagePushed"
          countUnit     = "days"
          countNumber   = 30
        }
        action = { type = "expire" }
      }
    ]
  })
}
