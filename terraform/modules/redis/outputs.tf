output "redis_endpoint" {
  description = "Primary endpoint address for the Redis cluster"
  value       = aws_elasticache_cluster.main.cache_nodes[0].address
}

output "redis_port" {
  description = "Port on which Redis accepts connections"
  value       = aws_elasticache_cluster.main.port
}

output "cluster_id" {
  description = "ID of the ElastiCache cluster"
  value       = aws_elasticache_cluster.main.cluster_id
}
