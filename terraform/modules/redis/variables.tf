variable "project_name" {
  description = "Project name for tagging"
  type        = string
}

variable "cluster_id" {
  description = "ElastiCache Redis cluster ID"
  type        = string
  default     = "toogle-redis"
}

variable "node_type" {
  description = "ElastiCache instance node type"
  type        = string
  default     = "cache.t3.medium"
}

variable "parameter_group_name" {
  description = "ElastiCache parameter group name"
  type        = string
  default     = "default.redis7"
}

variable "port" {
  description = "Redis port"
  type        = number
  default     = 6379
}

variable "subnet_group_name" {
  description = "ElastiCache subnet group name"
  type        = string
}

variable "security_group_ids" {
  description = "List of security group IDs"
  type        = list(string)
}
