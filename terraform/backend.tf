terraform {
  backend "s3" {
    bucket         = "tooglemaster-terraform-state"
    key            = "tooglemaster/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "tooglemaster-terraform-locks"
    encrypt        = true
  }
}
