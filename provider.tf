# Default AWS provider
provider "aws" {
  region     = var.AWS_REGION   # e.g., "us-east-1"
  access_key = var.access_key   # dummy AWS access key
  secret_key = var.secret_key   # dummy AWS secret key
}

# Secondary provider (with alias)
provider "aws" {
  alias      = "secondary"
  region     = "us-west-2"      # dummy example region
  access_key = var.access_key   # dummy AWS access key
  secret_key = var.secret_key   # dummy AWS secret key
}

# Data sources
data "aws_availability_zones" "available" {}

data "aws_caller_identity" "current" {}
