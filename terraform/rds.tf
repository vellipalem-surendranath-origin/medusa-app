# RDS Subnet Group
resource "aws_db_subnet_group" "default" {
  name       = "medusa-db-subnet-group"
  subnet_ids = module.vpc.private_subnets  # Use private subnets from your VPC

  tags = {
    Name = "medusa-db-subnet-group"
  }
}

# Security Group for RDS
resource "aws_security_group" "rds_sg" {
  name_prefix = "rds-sg"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    security_groups = [aws_security_group.ecs_sg.id]  # Allow access from ECS tasks
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# RDS Instance
resource "aws_db_instance" "medusa_db" {
  allocated_storage    = 20
  engine               = "postgres"
  engine_version       = "12.3"
  instance_class       = "db.t3.micro"
  name                 = "medusa"
  username             = var.db_username
  password             = var.db_password
  parameter_group_name = "default.postgres12"
  publicly_accessible  = false  # Set to false for security
  skip_final_snapshot  = true

  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  db_subnet_group_name      = aws_db_subnet_group.default.name
}
