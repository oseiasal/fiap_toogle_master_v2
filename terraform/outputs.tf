output "vpc_id" {
  description = "ID of the created VPC"
  value       = module.network.vpc_id
}

output "rds_auth_endpoint" {
  description = "Endpoint address for Auth DB"
  value       = module.rds.auth_db_endpoint
}

output "rds_main_endpoint" {
  description = "Endpoint address for Main DB"
  value       = module.rds.main_db_endpoint
}

output "rds_flag_endpoint" {
  description = "Endpoint address for Flag DB"
  value       = module.rds.flag_db_endpoint
}

output "rds_targeting_endpoint" {
  description = "Endpoint address for Targeting DB"
  value       = module.rds.targeting_db_endpoint
}

output "redis_endpoint" {
  description = "Primary endpoint address for ElastiCache Redis"
  value       = module.redis.redis_endpoint
}

output "sqs_url" {
  description = "URL of the SQS queue"
  value       = module.sqs.queue_url
}

output "ecr_repository_urls" {
  description = "Map of ECR repository names to their URLs"
  value       = module.ecr.repository_urls
}

output "eks_cluster_endpoint" {
  description = "Endpoint for EKS control plane"
  value       = module.eks.cluster_endpoint
}

output "eks_cluster_name" {
  description = "Name of the EKS cluster"
  value       = module.eks.cluster_name
}

output "db_password" {
  description = "Database master password"
  value       = var.db_password
  sensitive   = true
}

output "region" {
  description = "AWS region"
  value       = var.region
}
