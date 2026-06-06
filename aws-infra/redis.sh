#!/bin/bash

# ElastiCache Redis Cluster

echo "Creating ElastiCache Redis Cluster: toogle-redis..."
aws elasticache create-cache-cluster \
    --cache-cluster-id toogle-redis \
    --engine redis \
    --cache-node-type cache.t3.medium \
    --num-cache-nodes 1 \
    --tags Key=Project,Value=ToogleMaster > outputs/redis.json
