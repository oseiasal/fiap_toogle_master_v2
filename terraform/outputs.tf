output "vpc_id" {
  description = "ID of the created VPC"
  value       = module.network.vpc_id
}

output "vpc_cidr" {
  description = "CIDR block of the VPC"
  value       = module.network.vpc_cidr
}

# --- Subnets 3-Tier ---

output "public_subnet_ids" {
  description = "IDs of Tier 1 Public Subnets (ALB / Ingress / NAT)"
  value       = module.network.public_subnet_ids
}

output "private_app_subnet_ids" {
  description = "IDs of Tier 2 Private Application Subnets (EKS Compute / Redis)"
  value       = module.network.private_app_subnet_ids
}

output "isolated_db_subnet_ids" {
  description = "IDs of Tier 3 Isolated Database Subnets (RDS PostgreSQL)"
  value       = module.network.isolated_db_subnet_ids
}

output "nat_gateway_ip" {
  description = "Elastic IP address of the NAT Gateway"
  value       = module.network.nat_gateway_ip
}

# --- Security Groups ---

output "alb_security_group_id" {
  description = "Security Group ID for public Application Load Balancers"
  value       = module.network.alb_security_group_id
}

output "eks_nodes_security_group_id" {
  description = "Security Group ID for EKS Worker Nodes"
  value       = module.network.eks_nodes_security_group_id
}

output "rds_security_group_id" {
  description = "Security Group ID for RDS PostgreSQL"
  value       = module.network.rds_security_group_id
}

# --- Endpoints de Recursos ---

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

output "eks_cluster_endpoint" {
  description = "Endpoint for EKS control plane"
  value       = module.eks.cluster_endpoint
}

output "eks_cluster_name" {
  description = "Name of the EKS cluster"
  value       = module.eks.cluster_name
}


output "auth_db_secret_arn" {
  description = "Secrets Manager ARN for Auth DB master credentials"
  value       = module.rds.auth_master_user_secret_arn
}

output "flag_db_secret_arn" {
  description = "Secrets Manager ARN for Flag DB master credentials"
  value       = module.rds.flag_master_user_secret_arn
}

output "targeting_db_secret_arn" {
  description = "Secrets Manager ARN for Targeting DB master credentials"
  value       = module.rds.targeting_master_user_secret_arn
}

output "region" {
  description = "AWS region"
  value       = var.region
}

output "eso_role_arn" {
  description = "ARN of the IAM Role for External Secrets Operator IRSA"
  value       = module.iam.eso_role_arn
}



