resource "aws_db_instance" "medusa_db" {
  allocated_storage    = 20
  engine               = "postgres"
  engine_version       = "12.3"
  instance_class       = "db.t3.micro"
  name                 = "medusa"
  username             = var.db_username
  password             = var.db_password
  parameter_group_name = "default.postgres12"
  publicly_accessible  = true
  skip_final_snapshot  = true
  vpc_security_group_ids = [aws_security_group.rds_sg.id]

  subnet_group_name = aws_db_subnet_group.default.name
}
