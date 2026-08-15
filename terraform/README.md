# Infrastructure as Code with Terragrunt & Terraform - ToogleMaster

This directory contains the **Terragrunt & Terraform** modular infrastructure setup for the **ToogleMaster** microservices project.

---

## 🏗️ Architecture & Structure

```text
terraform/
├── terragrunt.hcl                             # Root Terragrunt config (Dynamic S3 Backend + AWS Provider)
├── main.tf                                    # Root Terraform module orchestration
├── variables.tf                               # Root Terraform input variables
├── outputs.tf                                 # Infrastructure outputs
├── deploy-helper.sh                           # Post-provisioning bridge for K8s .env files
├── modules/                                   # Reusable Terraform Modules
│   ├── iam/                                   # Dedicated EKS Control Plane & Node Group IAM Roles & Policies
│   ├── network/                               # VPC, Subnets (AZ-a/b), IGW, Route Tables, SG & Subnet Groups
│   ├── eks/                                   # EKS Cluster (v1.31) & Managed Node Group
│   ├── rds/                                   # PostgreSQL RDS instances (auth-db, main-db, targeting-db)
│   ├── redis/                                 # ElastiCache Redis Cluster
│   ├── dynamodb/                              # DynamoDB analytics_events Table (On-Demand)
│   ├── sqs/                                   # SQS toogle-events Queue
│   └── ecr/                                   # 5 ECR Repositories with Image Scan on push
└── environments/                              # Multi-Environment Stacks
    ├── dev/
    │   ├── env.hcl                            # Environment name ("dev")
    │   └── terragrunt.hcl                     # Dev inputs and execution settings
    ├── staging/
    │   ├── env.hcl                            # Environment name ("staging")
    │   └── terragrunt.hcl                     # Staging inputs and execution settings
    └── prod/
        ├── env.hcl                            # Environment name ("prod")
        └── terragrunt.hcl                     # Prod inputs and execution settings
```

---

## ⚡ Why Terragrunt?

1. **Automatic Remote State Creation:**  
   Terragrunt automatically creates the S3 Bucket and DynamoDB Lock Table in your AWS account on your first `terragrunt run` if they do not exist.
2. **DRY (Don't Repeat Yourself):**  
   Provider configurations and S3 State Locking are defined once in the root `terragrunt.hcl` and inherited across all environments (`dev`, `staging`, `prod`).
3. **Environment Isolation:**  
   Each environment maintains its own isolated `.tfstate` file in S3 (`dev/terraform.tfstate`, `prod/terraform.tfstate`).

---

## 🚀 Usage Guide

### 1. Authenticate with AWS
```powershell
aws sso login
$env:AWS_PROFILE="seu-perfil"
```

### 2. Plan an Environment (e.g., `dev`)
```powershell
cd environments/dev
terragrunt plan
```

### 3. Deploy an Environment (e.g., `dev`)
```powershell
cd environments/dev
terragrunt apply
```

### 4. Deploy All Environments / Multi-Stack
```powershell
cd environments
terragrunt run-all apply
```

### 5. Destroy / Teardown
```powershell
cd environments/dev
terragrunt destroy
```
