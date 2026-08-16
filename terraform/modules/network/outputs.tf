output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.main.id
}

output "vpc_cidr" {
  description = "CIDR block of the VPC"
  value       = aws_vpc.main.cidr_block
}

# --- Subnets por Camada (3 Tiers) ---

output "public_subnet_ids" {
  description = "IDs of Tier 1 Public Subnets (DMZ / ALB / NAT Gateway)"
  value       = aws_subnet.public[*].id
}

output "private_app_subnet_ids" {
  description = "IDs of Tier 2 Private Application Subnets (EKS Worker Nodes & Redis)"
  value       = aws_subnet.private_app[*].id
}

output "isolated_db_subnet_ids" {
  description = "IDs of Tier 3 Isolated Database Subnets (RDS PostgreSQL)"
  value       = aws_subnet.isolated_db[*].id
}

# --- Security Groups Especializados (Zero Trust) ---

output "alb_security_group_id" {
  description = "Security Group ID for public Application Load Balancers"
  value       = aws_security_group.alb.id
}

output "eks_nodes_security_group_id" {
  description = "Security Group ID for EKS Worker Nodes and pods"
  value       = aws_security_group.eks_nodes.id
}

output "rds_security_group_id" {
  description = "Security Group ID for RDS PostgreSQL instances"
  value       = aws_security_group.rds.id
}

output "redis_security_group_id" {
  description = "Security Group ID for ElastiCache Redis"
  value       = aws_security_group.redis.id
}

# --- Subnet Groups ---

output "db_subnet_group_name" {
  description = "Name of the DB subnet group (isolated database subnets)"
  value       = aws_db_subnet_group.main.name
}

output "elasticache_subnet_group_name" {
  description = "Name of the ElastiCache subnet group (private application subnets)"
  value       = aws_elasticache_subnet_group.main.name
}

output "nat_gateway_ip" {
  description = "Elastic IP address of the NAT Gateway"
  value       = aws_eip.nat.public_ip
}
