variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "bucket_name" {
  description = "Name of the S3 bucket for Terraform remote state (must be globally unique)"
  type        = string
  default     = "tooglemaster-terraform-state"
}

variable "dynamodb_table_name" {
  description = "Name of the DynamoDB table for Terraform state locking"
  type        = string
  default     = "tooglemaster-terraform-locks"
}
