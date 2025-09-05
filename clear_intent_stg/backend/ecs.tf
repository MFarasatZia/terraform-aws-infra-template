resource "aws_ecs_cluster" "clear-intent" {
  name = var.name
}
#############################################
# ECS Cluster 
#############################################

resource "aws_ecs_cluster" "this" {
  name = var.cluster_name

  setting {
    name  = "containerInsights"
    value = var.enable_container_insights ? "enabled" : "disabled"
  }

  tags = {
    Name = var.cluster_name
  }
}



