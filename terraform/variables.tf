variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "db_password" {
  description = "Database master password for RDS instances"
  type        = string
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
