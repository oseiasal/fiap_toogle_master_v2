# AWS Infrastructure Setup - ToogleMaster

This directory contains shell scripts to provision the necessary AWS infrastructure for the ToogleMaster project using the AWS CLI.

## Prerequisites

1.  **AWS CLI** installed and configured (`aws configure`).
2.  **Permissions**: Ensure your IAM user/role has permissions to create RDS, ECR, SQS, DynamoDB, and ElastiCache resources.
3.  **VPC/Network**: These scripts use default settings. For production, you should specify `--vpc-security-group-ids` and `--db-subnet-group-name` for RDS/ElastiCache.

## Resources Provisioned

- **RDS Postgres**:
    - `auth-db`: 20GB, t3.medium
    - `main-db`: 20GB, t3.medium
- **ECR Repositories**:
    - `analytics-service`
    - `auth-service`
    - `evaluation-service`
    - `flag-service`
    - `targeting-service`
- **SQS**:
    - `toogle-events`
- **DynamoDB**:
    - `analytics_events` (Partition Key: `event_id`)
- **Redis (ElastiCache)**:
    - `toogle-redis`: cache.t3.medium, single node

## Usage

To provision everything at once:

```bash
chmod +x setup-all.sh
./setup-all.sh
```

Or run individual scripts:

```bash
./rds.sh
./ecr.sh
./sqs.sh
./dynamodb.sh
./redis.sh
```

## Security Note

The RDS scripts use a placeholder password `change-me-securely`. **Change this password** before running the scripts or use AWS Secrets Manager to handle credentials.
