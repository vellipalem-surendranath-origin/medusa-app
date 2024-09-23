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
resource "aws_elasticache_subnet_group" "redis_subnet_group" {
  name       = "redis-subnet-group"
  subnet_ids = ["subnet-0c9b473d9397d8d61","subnet-0de0da3c4f069e929","subnet-01e20ef74422cd971"]
}

resource "aws_elasticache_cluster" "medusa" {
  cluster_id           = "medusa-redis"
  engine               = "redis"
  node_type            = "cache.m4.large"
  num_cache_nodes      = 1
  parameter_group_name = "default.redis7"
  port                 = 6379
  subnet_group_name    = aws_elasticache_subnet_group.redis_sg.name
  security_group_ids   = [aws_security_group.redis_sg.id]
}
