#!/bin/bash

# Master script to provision all AWS resources

echo "Starting AWS Infrastructure Provisioning for ToogleMaster..."

chmod +x rds.sh ecr.sh sqs.sh dynamodb.sh redis.sh

./ecr.sh
./rds.sh
./sqs.sh
./dynamodb.sh
./redis.sh

echo "Provisioning requests sent. Please monitor the AWS Console for completion status."
