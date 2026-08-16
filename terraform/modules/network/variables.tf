variable "project_name" {
  description = "Project name for tagging and resource naming"
  type        = string
}

variable "cluster_name" {
  description = "EKS Cluster name for Kubernetes subnet tags"
  type        = string
  default     = "toogle-cluster"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for Tier 1: Public Subnets (Ingress / ALB / NAT)"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_app_subnet_cidrs" {
  description = "CIDR blocks for Tier 2: Private Application Subnets (EKS Compute / Redis)"
  type        = list(string)
  default     = ["10.0.10.0/24", "10.0.20.0/24"]
}

variable "isolated_db_subnet_cidrs" {
  description = "CIDR blocks for Tier 3: Isolated Database Subnets (RDS PostgreSQL)"
  type        = list(string)
  default     = ["10.0.30.0/24", "10.0.40.0/24"]
}
