output "auth_secret_arn" {
  description = "ARN of the Auth Service secret"
  value       = aws_secretsmanager_secret.auth.arn
}

output "flag_secret_arn" {
  description = "ARN of the Flag Service secret"
  value       = aws_secretsmanager_secret.flag.arn
}

output "targeting_secret_arn" {
  description = "ARN of the Targeting Service secret"
  value       = aws_secretsmanager_secret.targeting.arn
}

output "evaluation_secret_arn" {
  description = "ARN of the Evaluation Service secret"
  value       = aws_secretsmanager_secret.evaluation.arn
}

output "analytics_secret_arn" {
  description = "ARN of the Analytics Service secret"
  value       = aws_secretsmanager_secret.analytics.arn
}

output "eso_policy_arn" {
  description = "ARN of the IAM policy for External Secrets Operator"
  value       = aws_iam_policy.external_secrets_access.arn
}
