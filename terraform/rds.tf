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
  vpc_security_group_ids = [aws_security_group.medusa_sg.id]
  db_subnet_group_name = data.aws_subnet.main.name
}

