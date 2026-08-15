variable "project_name" {
  description = "Project name for tagging"
  type        = string
}

variable "services" {
  description = "List of microservice repository names to create"
  type        = list(string)
  default = [
    "analytics-service",
    "auth-service",
    "evaluation-service",
    "flag-service",
    "targeting-service"
  ]
}

variable "image_tag_mutability" {
  description = "The tag mutability setting for the repository"
  type        = string
  default     = "MUTABLE"
}

variable "force_delete" {
  description = "If true, will delete the repository even if it contains images"
  type        = bool
  default     = true
}

variable "scan_on_push" {
  description = "Indicates whether images are scanned after being pushed to the repository"
  type        = bool
  default     = true
}
