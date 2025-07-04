#!/bin/bash
echo "Cleaning up Terraform and Kubernetes resources..."
find . -name ".terraform" -type d -exec rm -rf {} +
find . -name "*.tfstate*" -delete
kubectl delete -f examples/k8s/ --ignore-not-found
