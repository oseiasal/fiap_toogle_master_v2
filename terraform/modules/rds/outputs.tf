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
