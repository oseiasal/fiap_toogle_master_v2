# Infrastructure as Code with Terraform - ToogleMaster (Modular)

This directory contains the modular Terraform configuration to provision and manage the AWS infrastructure for the **ToogleMaster** microservices project.

---

## 🏗️ Architecture & Modules

The infrastructure is organized into dedicated reusable modules located in [`modules/`](file:///C:/Users/oseia/OneDrive/Área%20de%20Trabalho/FIAP_MODULO_3/fiap_toogle_master_v2/terraform/modules):

```text
terraform/
├── backend.tf                         # Remote state configuration (S3 + DynamoDB Locking)
├── main.tf                            # Root module orchestration
├── providers.tf                       # Terraform & AWS provider setup
├── variables.tf                       # Root variables
├── terraform.tfvars                   # Variable assignments (local/secrets)
├── terraform.tfvars.example           # Example variable definitions
├── outputs.tf                         # Infrastructure outputs for scripts & K8s
├── deploy-helper.sh                   # Post-provisioning bridge for K8s .env generation
├── backend-bootstrap/                 # Optional bootstrap IaC for S3 State Bucket & Lock Table
│   ├── main.tf
│   ├── variables.tf
│   └── outputs.tf
└── modules/
    ├── network/                       # VPC, Subnets (AZ-a/b), IGW, Route Tables, SG & Subnet Groups
    ├── eks/                           # EKS Cluster (v1.31) & Managed Node Group
    ├── rds/                           # PostgreSQL RDS instances (auth-db, main-db, targeting-db)
    ├── redis/                         # ElastiCache Redis Cluster
    ├── dynamodb/                      # DynamoDB analytics_events Table (On-Demand)
    ├── sqs/                           # SQS toogle-events Queue
    └── ecr/                           # 5 ECR Repositories with Image Scan on push
```

---

## 🔒 Remote State Backend (S3 + DynamoDB)

State locking and shared remote state are configured in [`backend.tf`](file:///C:/Users/oseia/OneDrive/Área%20de%20Trabalho/FIAP_MODULO_3/fiap_toogle_master_v2/terraform/backend.tf):

```hcl
terraform {
  backend "s3" {
    bucket         = "tooglemaster-terraform-state"
    key            = "tooglemaster/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "tooglemaster-terraform-locks"
    encrypt        = true
  }
}
```

> **Bootstrap Note:** If you are provisioning in a new AWS account, you can create the S3 bucket and DynamoDB lock table first by running `terraform apply` inside [`backend-bootstrap/`](file:///C:/Users/oseia/OneDrive/Área%20de%20Trabalho/FIAP_MODULO_3/fiap_toogle_master_v2/terraform/backend-bootstrap).

---

## 🚀 Usage

### 1. Configure Variables
Copy the template and configure your values (such as `db_password`):
```bash
cp terraform.tfvars.example terraform.tfvars
```

### 2. Initialize Terraform
```bash
terraform init
```

*(If testing locally without AWS S3 backend created yet, you can run `terraform init -backend=false`)*

### 3. Review Plan
```bash
terraform plan
```

### 4. Provision Infrastructure
```bash
terraform apply
```

### 5. Generate Kubernetes `.env` & Post-Deploy
Run the deploy helper script to automatically inject RDS/Redis/SQS endpoints into the Kubernetes Kustomize environment:
```bash
./deploy-helper.sh
```

### 6. Teardown / Cleanup
```bash
terraform destroy
```
