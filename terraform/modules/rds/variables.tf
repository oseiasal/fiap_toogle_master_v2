variable "project_name" {
  description = "Project name for tagging"
  type        = string
}

variable "db_password" {
  description = "Database master password"
  type        = string
  sensitive   = true
}

variable "db_username" {
  description = "Database master username"
  type        = string
  default     = "dbuser"
}

variable "instance_class" {
  description = "RDS instance type"
  type        = string
  default     = "db.t3.medium"
}

variable "allocated_storage" {
  description = "Allocated storage in gigabytes"
  type        = number
  default     = 20
}

variable "db_subnet_group_name" {
  description = "DB subnet group name (pointing to isolated database subnets)"
  type        = string
}

variable "security_group_ids" {
  description = "List of security group IDs for RDS"
  type        = list(string)
}

variable "publicly_accessible" {
  description = "Whether the DB instance is publicly accessible (Default: false for 3-tier isolation)"
  type        = bool
  default     = false
}
