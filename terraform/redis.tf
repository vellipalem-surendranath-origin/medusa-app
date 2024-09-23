resource "aws_elasticache_subnet_group" "redis_subnet_group" {
  name       = "redis-subnet-group"
  subnet_ids = ["subnet-0c9b473d9397d8d61"]
}


resource "aws_elasticache_replication_group" "default" {
  replication_group_id          = "medusa-redis"
  replication_group_description = "Redis cluster for medusa backend"

  node_type            = "cache.m4.large"
  port                 = 6379
  parameter_group_name = "default.redis3.2.cluster.on"

  snapshot_retention_limit = 5
  snapshot_window          = "00:00-05:00"

  subnet_group_name          = aws_elasticache_subnet_group.redis_subnet_group.name
  automatic_failover_enabled = true

  cluster_mode {
    replicas_per_node_group = 1
    num_node_groups         = 3
  }
  depends_on = [
    aws_elasticache_subnet_group.redis_subnet_group
  ]
}
