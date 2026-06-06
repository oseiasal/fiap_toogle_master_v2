#!/bin/bash

# Master script to delete all provisioned AWS resources for ToogleMaster
# WARNING: This will permanently delete your data and infrastructure.

echo "!!! WARNING: Starting AWS Infrastructure Destruction for ToogleMaster !!!"
read -p "Are you sure you want to delete everything? (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]
then
    echo "Deletion cancelled."
    exit 1
fi

# 1. Delete RDS Instances
echo "Deleting RDS Instances (auth-db, main-db)..."
aws rds delete-db-instance --db-instance-identifier auth-db --skip-final-snapshot
aws rds delete-db-instance --db-instance-identifier main-db --skip-final-snapshot

# 2. Delete ECR Repositories
SERVICES=("analytics-service" "auth-service" "evaluation-service" "flag-service" "targeting-service")
for service in "${SERVICES[@]}"; do
    echo "Deleting ECR repository: $service..."
    aws ecr delete-repository --repository-name "$service" --force
done

# 3. Delete SQS Queue
echo "Deleting SQS Queue: toogle-events..."
# We need the URL to delete, or we can use the name if we query it
QUEUE_URL=$(aws sqs get-queue-url --queue-name toogle-events --query 'QueueUrl' --output text 2>/dev/null)
if [ ! -z "$QUEUE_URL" ]; then
    aws sqs delete-queue --queue-url "$QUEUE_URL"
fi

# 4. Delete DynamoDB Table
echo "Deleting DynamoDB Table: analytics_events..."
aws dynamodb delete-table --table-name analytics_events

# 5. Delete ElastiCache Redis
echo "Deleting ElastiCache Redis Cluster: toogle-redis..."
aws elasticache delete-cache-cluster --cache-cluster-id toogle-redis

# 6. Clean up output files
echo "Cleaning up local output files..."
rm -rf outputs/*.json

echo "Deletion requests sent. Resources may take a few minutes to be fully removed."
