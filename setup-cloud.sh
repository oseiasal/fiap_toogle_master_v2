#!/bin/bash
set -e
git submodule update --init --recursive

# Update EKS Kubeconfig
# aws eks update-kubeconfig --region us-east-1 --name toogle-cluster
