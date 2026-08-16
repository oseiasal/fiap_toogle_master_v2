terraform {
  required_version = ">= 1.5.0"

  # Backend S3 configurado e injetado dinamicamente pelo Terragrunt
  backend "s3" {}

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}
