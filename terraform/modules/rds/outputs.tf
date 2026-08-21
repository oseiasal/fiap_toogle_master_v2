output "auth_db_endpoint" {
  description = "Connection endpoint for Auth DB"
  value       = aws_db_instance.auth_db.endpoint
}

output "auth_db_address" {
  description = "Hostname of the Auth DB instance"
  value       = aws_db_instance.auth_db.address
}

output "main_db_endpoint" {
  description = "Connection endpoint for Main/Flag DB"
  value       = aws_db_instance.main_db.endpoint
}

output "flag_db_endpoint" {
  description = "Connection endpoint for Flag DB (alias for main_db)"
  value       = aws_db_instance.main_db.endpoint
}

output "main_db_address" {
  description = "Hostname of the Main/Flag DB instance"
  value       = aws_db_instance.main_db.address
}

output "targeting_db_endpoint" {
  description = "Connection endpoint for Targeting DB"
  value       = aws_db_instance.targeting_db.endpoint
}

output "targeting_db_address" {
  description = "Hostname of the Targeting DB instance"
  value       = aws_db_instance.targeting_db.address
}

output "auth_master_user_secret_arn" {
  description = "ARN of the secret generated in Secrets Manager for Auth DB"
  value       = aws_db_instance.auth_db.master_user_secret[0].secret_arn
}

output "flag_master_user_secret_arn" {
  description = "ARN of the secret generated in Secrets Manager for Flag DB"
  value       = aws_db_instance.main_db.master_user_secret[0].secret_arn
}

output "targeting_master_user_secret_arn" {
  description = "ARN of the secret generated in Secrets Manager for Targeting DB"
  value       = aws_db_instance.targeting_db.master_user_secret[0].secret_arn
}

