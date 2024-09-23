resource "aws_elasticache_subnet_group" "redis_subnet_group" {
  name       = "redis-subnet-group"
  subnet_ids = ["subnet-0c9b473d9397d8d61"]
}

resource "aws_elasticache_cluster" "redis" {
  cluster_id           = "medusa-redis"
  engine               = "redis"
  node_type            = "cache.t3.micro"
  num_cache_nodes      = 1
  parameter_group_name = "default.redis5.0"
  subnet_group_name    = aws_elasticache_subnet_group.redis_subnet_group.name
  security_group_ids   = [aws_security_group.medusa_sg.id]
 depends_on = [
    aws_elasticache_subnet_group.redis_subnet_group
  ]
}
