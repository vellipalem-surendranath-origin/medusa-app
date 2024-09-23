resource "aws_security_group" "redis_sg" {
  name        = "redis_sg"
  description = "Allow Redis access"
  vpc_id      = data.aws_vpc.main.id

  ingress {
    from_port   = 6379
    to_port     = 6379
    protocol    = "tcp"
    # Replace with the appropriate CIDR or security group for access
    cidr_blocks = ["0.0.0.0/0"]  # Example: Replace with your application's CIDR block
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_db_subnet_group" "db_subnet" {
  name       = "medusa-db-subnet-group"
  subnet_ids = ["subnet-0c9b473d9397d8d61"]
  description = "Subnet group for Medusa PostgreSQL RDS"
}

resource "aws_db_instance" "medusa_db" {
  allocated_storage    = 20
  engine               = "postgres"
  engine_version       = "16.1"
  instance_class       = "db.t3.micro"
  name                 = "medusa"
  username             = "medusa_user"
  password             = "medusa123"
  parameter_group_name = "default.postgres16"
  publicly_accessible  = true
  vpc_security_group_ids = [aws_security_group.redis_sg.id]
  db_subnet_group_name = aws_db_subnet_group.db_subnet.name
}

