variable "project_name" {
  description = "Project name for tagging and resource naming"
  type        = string
}

variable "create_iam_roles" {
  description = "Set to true to create dedicated IAM roles/policies (Personal AWS), or false to use existing LabRole (AWS Academy)"
  type        = bool
  default     = true
}

variable "lab_role_name" {
  description = "Name of existing LabRole if create_iam_roles is false"
  type        = string
  default     = "LabRole"
}

variable "oidc_provider_arn" {
  description = "ARN of the EKS OIDC Provider"
  type        = string
  default     = ""
}

variable "oidc_provider_url" {
  description = "URL of the EKS OIDC Provider"
  type        = string
  default     = ""
}
