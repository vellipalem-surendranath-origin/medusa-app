output "medusa_service_url" {
  value = aws_ecs_service.medusa_service.name
}

output "postgres_endpoint" {
  value = aws_db_instance.medusa_db.endpoint
}

output "redis_endpoint" {
  value = aws_elasticache_replication_group.default.primary_endpoint_address
}
