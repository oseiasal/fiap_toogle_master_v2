locals {
  prefix = "/tooglemaster/${var.environment}"
}

# 1. Contêiner de Segredo para Auth Service (Agnóstico ao Terraform)
resource "aws_secretsmanager_secret" "auth" {
  name                    = "${local.prefix}/auth"
  description             = "Credenciais e chaves de runtime para o auth-service"
  recovery_window_in_days = 0

  tags = {
    Project     = var.project_name
    Environment = var.environment
    Service     = "auth-service"
    ManagedBy   = "Terraform"
  }
}

# 2. Contêiner de Segredo para Flag Service (Agnóstico ao Terraform)
resource "aws_secretsmanager_secret" "flag" {
  name                    = "${local.prefix}/flag"
  description             = "Credenciais e chaves de runtime para o flag-service"
  recovery_window_in_days = 0

  tags = {
    Project     = var.project_name
    Environment = var.environment
    Service     = "flag-service"
    ManagedBy   = "Terraform"
  }
}

# 3. Contêiner de Segredo para Targeting Service (Agnóstico ao Terraform)
resource "aws_secretsmanager_secret" "targeting" {
  name                    = "${local.prefix}/targeting"
  description             = "Credenciais e chaves de runtime para o targeting-service"
  recovery_window_in_days = 0

  tags = {
    Project     = var.project_name
    Environment = var.environment
    Service     = "targeting-service"
    ManagedBy   = "Terraform"
  }
}

# 4. Contêiner de Segredo para Evaluation Service (Agnóstico ao Terraform)
resource "aws_secretsmanager_secret" "evaluation" {
  name                    = "${local.prefix}/evaluation"
  description             = "Credenciais e chaves de runtime para o evaluation-service"
  recovery_window_in_days = 0

  tags = {
    Project     = var.project_name
    Environment = var.environment
    Service     = "evaluation-service"
    ManagedBy   = "Terraform"
  }
}

# 5. Contêiner de Segredo para Analytics Service (Agnóstico ao Terraform)
resource "aws_secretsmanager_secret" "analytics" {
  name                    = "${local.prefix}/analytics"
  description             = "Credenciais e chaves de runtime para o analytics-service"
  recovery_window_in_days = 0

  tags = {
    Project     = var.project_name
    Environment = var.environment
    Service     = "analytics-service"
    ManagedBy   = "Terraform"
  }
}

# IAM Policy para o External Secrets Operator (IRSA)
resource "aws_iam_policy" "external_secrets_access" {
  name        = "${lower(var.project_name)}-eso-secrets-policy"
  description = "Permite ao External Secrets Operator ler segredos do ToogleMaster na AWS"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetResourcePolicy",
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret",
          "secretsmanager:ListSecretVersionIds"
        ]
        Resource = [
          aws_secretsmanager_secret.auth.arn,
          aws_secretsmanager_secret.flag.arn,
          aws_secretsmanager_secret.targeting.arn,
          aws_secretsmanager_secret.evaluation.arn,
          aws_secretsmanager_secret.analytics.arn
        ]
      }
    ]
  })

  tags = {
    Project   = var.project_name
    ManagedBy = "Terraform"
  }
}
