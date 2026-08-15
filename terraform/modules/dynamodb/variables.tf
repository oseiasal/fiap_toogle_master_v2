variable "project_name" {
  description = "Project name for tagging"
  type        = string
}

variable "table_name" {
  description = "DynamoDB table name"
  type        = string
  default     = "analytics_events"
}

variable "billing_mode" {
  description = "Controls how you are charged for read and write throughput"
  type        = string
  default     = "PAY_PER_REQUEST"
}

variable "hash_key" {
  description = "The attribute to use as the hash key"
  type        = string
  default     = "event_id"
}
