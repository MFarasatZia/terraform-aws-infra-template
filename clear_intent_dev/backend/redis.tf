#############################################
# Redis Security Group — allow only from App SG
#############################################
resource "aws_security_group" "redis" {
  name        = "${var.name_prefix}-redis-sg"
  description = "Allow Redis from app service"
  vpc_id      = var.vpc_id

  ingress {
    description     = "App → Redis"
    from_port       = var.redis_port
    to_port         = var.redis_port
    protocol        = "tcp"
    security_groups = [var.app_sg_id]
  }

  # Egress (for patching/monitoring as needed)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "${var.name_prefix}-redis-sg" }
}

#############################################
# Subnet Group — private subnets
#############################################
resource "aws_elasticache_subnet_group" "redis" {
  name       = "${var.name_prefix}-redis-subnets"
  subnet_ids = var.private_subnet_ids
  tags       = { Name = "${var.name_prefix}-redis-subnets" }
}

#############################################
# Redis (single-node demo) — ElastiCache cluster
# For production HA, prefer aws_elasticache_replication_group.
#############################################
resource "aws_elasticache_cluster" "redis" {
  cluster_id           = "${var.name_prefix}-redis"
  engine               = "redis"
  engine_version       = var.redis_engine_version     # e.g., "7.x" or "6.x"
  node_type            = var.redis_node_type          # e.g., "cache.t3.micro"
  num_cache_nodes      = var.redis_node_count         # 1 for demo
  port                 = var.redis_port
  parameter_group_name = var.redis_parameter_group    # e.g., "default.redis7"

  subnet_group_name  = aws_elasticache_subnet_group.redis.name
  security_group_ids = [aws_security_group.redis.id]

  tags = { Name = "${var.name_prefix}-redis" }
}
