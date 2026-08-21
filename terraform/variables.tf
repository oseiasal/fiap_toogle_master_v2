variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "db_password" {
  description = "Database master password for RDS instances"
  type        = string
  default     = "DevSenhaMaster123!"
  sensitive   = true
}


variable "create_iam_roles" {
  description = "Set to true to create dedicated IAM Roles and Policies (Personal AWS account), or false to use existing LabRole (AWS Academy)"
  type        = bool
  default     = true
}

variable "lab_role_name" {
  description = "The name of the IAM role to use if create_iam_roles is false (for AWS Academy/Lab environments)"
  type        = string
  default     = "LabRole"
}

variable "project_name" {
  description = "Project name for tagging and resource naming"
  type        = string
  default     = "ToogleMaster"
}

variable "k8s_version" {
  description = "Kubernetes version for EKS cluster"
  type        = string
  default     = "1.31"
}

# --- Capacidade e Dimensionamento (EKS, RDS, Redis) ---

variable "eks_instance_types" {
  description = "EC2 instance types for EKS worker nodes (ex: ['t3.small'], ['t3.medium'])"
  type        = list(string)
  default     = ["t3.medium"]
}

variable "eks_desired_size" {
  description = "Desired number of worker nodes in EKS"
  type        = number
  default     = 2
}

variable "eks_min_size" {
  description = "Minimum number of worker nodes in EKS"
  type        = number
  default     = 1
}

variable "eks_max_size" {
  description = "Maximum number of worker nodes in EKS"
  type        = number
  default     = 3
}

variable "eks_ami_type" {
  description = "AMI Type for EKS Worker Nodes (e.g., AL2023_ARM_64_STANDARD, AL2023_x86_64_STANDARD)"
  type        = string
  default     = "AL2023_x86_64_STANDARD"
}



variable "rds_instance_class" {
  description = "RDS PostgreSQL instance class (ex: 'db.t3.micro', 'db.t3.small', 'db.t3.medium')"
  type        = string
  default     = "db.t3.medium"
}

variable "rds_allocated_storage" {
  description = "Allocated storage in GB for RDS instances"
  type        = number
  default     = 20
}

variable "rds_multi_az" {
  description = "Specifies if RDS instances are multi-AZ (Default: false for Single-AZ)"
  type        = bool
  default     = false
}

variable "redis_node_type" {
  description = "ElastiCache Redis node type (ex: 'cache.t3.micro', 'cache.t3.small', 'cache.t3.medium')"
  type        = string
  default     = "cache.t3.medium"
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "master_key" {
  description = "Master API Key for Auth Service"
  type        = string
  default     = "sua_chave_mestra_aqui"
  sensitive   = true
}

variable "service_api_key" {
  description = "Internal service API key for microservice communication"
  type        = string
  default     = "tm_key_f54b81bc161a5b84c277ed954384ae950c87adb8c795892db4abfaef75aaacab"
  sensitive   = true
}

