locals {
  # Carrega variáveis específicas do ambiente a partir do env.hcl da pasta filha
  env_vars = read_terragrunt_config(find_in_parent_folders("env.hcl", "fallback.hcl"), {
    locals = {
      environment = "dev"
    }
  })

  environment  = local.env_vars.locals.environment
  aws_region   = "us-east-1"
  project_name = "ToogleMaster"
}

# Gera dinamicamente o provider AWS com tags padronizadas
generate "provider" {
  path      = "provider_override.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
provider "aws" {
  region = "${local.aws_region}"

  default_tags {
    tags = {
      Project     = "${local.project_name}"
      Environment = "${local.environment}"
      ManagedBy   = "Terragrunt"
    }
  }
}
EOF
}

# Configura e cria automaticamente o Backend remoto no S3 com State Lock via DynamoDB
remote_state {
  backend = "s3"
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
  config = {
    bucket         = "tooglemaster-terragrunt-state-${get_aws_account_id()}"
    key            = "${path_relative_to_include()}/terraform.tfstate"
    region         = local.aws_region
    encrypt        = true
    dynamodb_table = "tooglemaster-terragrunt-locks"
  }
}
