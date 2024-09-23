resource "aws_elasticache_subnet_group" "redis_subnet_group" {
  name       = "redis-subnet-group"
  subnet_ids = ["subnet-0c9b473d9397d8d61"]
}

resource "aws_elasticache_cluster" "medusa" {
  cluster_id           = "medusa-redis"
  engine               = "redis"
  node_type            = "cache.m4.large"
  num_cache_nodes      = 1
  parameter_group_name = "default.redis6.x"
  engine_version       = "6.2"
  port                 = 6379
  subnet_group_name          = aws_elasticache_subnet_group.redis_subnet_group.name
  depends_on = [
    aws_elasticache_subnet_group.redis_subnet_group
  ]
}
