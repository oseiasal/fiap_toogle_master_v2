# Infrastructure as Code with Terragrunt & Terraform - ToogleMaster

This directory contains the **Terragrunt & Terraform** modular infrastructure setup for the **ToogleMaster** microservices project.

---

## 🏗️ Architecture & Structure

```text
terraform/
├── terragrunt.hcl                             # Root Terragrunt config (Dynamic S3 Backend + AWS Provider)
├── main.tf                                    # Root Terraform module orchestration (Compute & Data)
├── variables.tf                               # Root Terraform input variables
├── outputs.tf                                 # Infrastructure outputs
├── versions.tf                                # Terraform & AWS Provider versions
├── INVENTARIO.md                              # Detailed Architecture, Resource Inventory & AWS Cost Matrix
├── deploy-helper.sh                           # Post-provisioning bridge for K8s .env files
├── modules/                                   # Reusable Terraform Modules
│   ├── iam/                                   # Dedicated EKS Control Plane & Node Group IAM Roles & Policies
│   ├── network/                               # 3-Tier VPC, Subnets (AZ-a/b), IGW, NAT Gateway, SGs
│   ├── eks/                                   # EKS Cluster (v1.31) & Managed Node Group
│   ├── rds/                                   # PostgreSQL RDS instances (auth-db, main-db, targeting-db)
│   ├── redis/                                 # ElastiCache Redis Cluster
│   ├── dynamodb/                              # DynamoDB analytics_events Table (On-Demand)
│   ├── sqs/                                   # SQS toogle-events Queue
│   └── ecr/                                   # 5 ECR Repositories with Image Scan on push
└── environments/                              # Multi-Stack Environments
    ├── shared/                                # 🌟 Shared & Persistent Layer (Created once, independent)
    │   └── ecr/
    │       ├── env.hcl                        # environment = "shared"
    │       └── terragrunt.hcl                 # 5 ECR Repositories for Docker Images
    ├── dev/                                   # 🔄 Ephemeral Runtime Layer (Spin up & Tear down anytime)
    │   ├── env.hcl                            # environment = "dev"
    │   └── terragrunt.hcl                     # VPC 3-Tier, EKS, RDS, Redis, SQS, DynamoDB
    ├── staging/
    │   ├── env.hcl                            # environment = "staging"
    │   └── terragrunt.hcl
    └── prod/
        ├── env.hcl                            # environment = "prod"
        └── terragrunt.hcl
```

---

## ⚡ Why Separate ECR from Dev/Prod Environments?

1. **Persistent Container Registries:**  
   Docker images built by CI/CD pipelines (GitHub Actions) remain safe in ECR even when the Kubernetes cluster or RDS databases are destroyed to save costs.
2. **Cost-Effective Teardown:**  
   Running `terragrunt destroy` inside `environments/dev` removes EC2, RDS, and NAT Gateway without wiping out your Docker images.

---

## 🚀 Usage Guide

### 1. Authenticate with AWS
```bash
aws login --profile login
```

### 2. Provision Shared ECR Repositories (Once)
```bash
cd environments/shared/ecr
terragrunt apply
```

### 3. Deploy Dev Environment (Runtime Compute & Data)
```bash
cd environments/dev
terragrunt plan
terragrunt apply
```

### 4. Teardown Dev Environment (Zero Running Cost)
```bash
cd environments/dev
terragrunt destroy
```
*(Your ECR repositories and Docker images stay 100% intact!)*
