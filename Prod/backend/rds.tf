#############################################
# App SG (ECS service) — only ALB can reach 8000
#############################################
resource "aws_security_group" "app" {
  name        = "${var.name_prefix}-${var.service_name}-sg"
  description = "Allow ALB → app on ${var.app_port}"
  vpc_id      = var.vpc_id

  # App traffic from ALB only (no SSH on Fargate)
  ingress {
    from_port       = var.app_port
    to_port         = var.app_port
    protocol        = "tcp"
    security_groups = [var.alb_sg_id]
  }

  # Outbound allowed (egress to internet via NAT for updates etc.)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "${var.name_prefix}-${var.service_name}-sg" }
}

#############################################
# DB SG — allow from app SG (and optional bastion)
#############################################
resource "aws_security_group" "db" {
  name        = "${var.name_prefix}-db-sg"
  description = "Allow app (and optional bastion) to Postgres"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = compact([aws_security_group.app.id, var.bastion_sg_id])
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "${var.name_prefix}-db-sg" }
}

#############################################
# RDS subnet/parameter groups (private)
#############################################
resource "aws_db_subnet_group" "db" {
  name        = "${var.name_prefix}-db-subnet"
  description = "RDS subnets (private)"
  subnet_ids  = var.private_subnet_ids

  lifecycle { create_before_destroy = true }
}

resource "aws_db_parameter_group" "db" {
  name        = "${var.name_prefix}-db-params"
  family      = "postgres15"
  description = "PostgreSQL parameters"

  parameter {
    name         = "max_connections"
    value        = "105"
    apply_method = "pending-reboot"
  }
}

#############################################
# RDS instance (private, gp3, no AZ pinning)
#############################################
resource "aws_db_instance" "db" {
  identifier              = "${var.name_prefix}-postgres"
  engine                  = "postgres"
  engine_version          = var.db_engine_version
  instance_class          = var.db_instance_class
  allocated_storage       = var.db_allocated_storage
  storage_type            = "gp3"
  storage_encrypted       = true
  db_subnet_group_name    = aws_db_subnet_group.db.name
  parameter_group_name    = aws_db_parameter_group.db.name
  vpc_security_group_ids  = [aws_security_group.db.id]
  multi_az                = var.db_multi_az
  publicly_accessible     = false
  backup_retention_period = var.db_backup_retention_days
  deletion_protection     = var.db_deletion_protection
  skip_final_snapshot     = var.db_skip_final_snapshot

  username = var.db_username
  password = var.db_password   # <- pass via tfvars/CI; do NOT commit

  tags = { Name = "${var.name_prefix}-postgres" }

  lifecycle {
    ignore_changes = [engine_version, snapshot_identifier, password]
  }
}

#############################################
# Outputs
#############################################
output "db_host"        { value = aws_db_instance.db.address }
output "app_sg_id"      { value = aws_security_group.app.id }
output "db_sg_id"       { value = aws_security_group.db.id }
