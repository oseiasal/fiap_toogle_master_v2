#!/bin/bash

# Script to create an EKS Cluster and Node Group using AWS CLI (No eksctl)
# Optimized for Lab Environments (using LabRole)

CLUSTER_NAME="toogle-cluster"
NODE_GROUP_NAME="toogle-nodes"
REGION=$(aws configure get region)
REGION=${REGION:-us-east-1}

# LAB_ROLE_NAME is standard in AWS Academy/VocLabs
LAB_ROLE_NAME="LabRole"

echo "Starting EKS Cluster Provisioning for Lab: $CLUSTER_NAME..."

# 1. Fetch Networking Info
VPC_ID=$(aws ec2 describe-vpcs --filters "Name=tag:Name,Values=toogle-vpc" --query 'Vpcs[0].VpcId' --output text)
SUBNET_IDS=$(aws ec2 describe-subnets --filters "Name=vpc-id,Values=$VPC_ID" --query 'Subnets[*].SubnetId' --output text | sed 's/\t/,/g')

if [ -z "$VPC_ID" ] || [ "$VPC_ID" == "None" ]; then
    echo "Error: VPC 'toogle-vpc' not found. Run networking.sh first."
    exit 1
fi

# 2. Get LabRole ARN
echo "Fetching LabRole ARN..."
LAB_ROLE_ARN=$(aws iam get-role --role-name "$LAB_ROLE_NAME" --query 'Role.Arn' --output text 2>/dev/null)

if [ -z "$LAB_ROLE_ARN" ] || [ "$LAB_ROLE_ARN" == "None" ]; then
    echo "Error: Could not find IAM Role '$LAB_ROLE_NAME'. Please verify the role name in your Lab console."
    exit 1
fi

echo "Using Role: $LAB_ROLE_ARN"

# 3. Create EKS Cluster
if ! aws eks describe-cluster --name "$CLUSTER_NAME" >/dev/null 2>&1; then
    echo "Creating EKS Cluster (this takes ~10-15 minutes)..."
    aws eks create-cluster \
        --name "$CLUSTER_NAME" \
        --role-arn "$LAB_ROLE_ARN" \
        --resources-vpc-config subnetIds="$SUBNET_IDS" \
        --tags Project=ToogleMaster
    
    echo "Waiting for cluster to reach ACTIVE state..."
    aws eks wait cluster-active --name "$CLUSTER_NAME"
    echo "EKS Cluster is ACTIVE."
else
    echo "EKS Cluster $CLUSTER_NAME already exists."
fi

# 4. Create Node Group
STATUS=$(aws eks describe-nodegroup --cluster-name "$CLUSTER_NAME" --nodegroup-name "$NODE_GROUP_NAME" --query 'nodegroup.status' --output text 2>/dev/null)

if [ "$STATUS" == "CREATE_FAILED" ] || [ "$STATUS" == "DEGRADED" ]; then
    echo "Node Group $NODE_GROUP_NAME is in state $STATUS. Deleting to retry..."
    aws eks delete-nodegroup --cluster-name "$CLUSTER_NAME" --nodegroup-name "$NODE_GROUP_NAME"
    echo "Waiting for Node Group to be deleted..."
    aws eks wait nodegroup-deleted --cluster-name "$CLUSTER_NAME" --nodegroup-name "$NODE_GROUP_NAME"
    STATUS=""
fi

if [ -z "$STATUS" ] || [ "$STATUS" == "None" ]; then
    echo "Creating Managed Node Group..."
    aws eks create-nodegroup \
        --cluster-name "$CLUSTER_NAME" \
        --nodegroup-name "$NODE_GROUP_NAME" \
        --node-role "$LAB_ROLE_ARN" \
        --subnets $(echo "$SUBNET_IDS" | tr ',' ' ') \
        --scaling-config minSize=1,maxSize=3,desiredSize=2 \
        --instance-types t3.medium \
        --capacity-type ON_DEMAND \
        --tags Project=ToogleMaster
    
    echo "Waiting for Node Group to reach ACTIVE state..."
    aws eks wait nodegroup-active --cluster-name "$CLUSTER_NAME" --nodegroup-name "$NODE_GROUP_NAME"
    echo "Node Group is ACTIVE."
else
    echo "Node Group $NODE_GROUP_NAME already exists."
fi

# 5. Update Kubeconfig
echo "Updating local kubeconfig..."
aws eks update-kubeconfig --name "$CLUSTER_NAME" --region "$REGION"

echo "EKS Setup Complete."
