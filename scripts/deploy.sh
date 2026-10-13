#!/bin/bash
set -euo pipefail

ENVIRONMENT="${1:?Provide dev, qa or prod}"
TAG="${2:?Provide an image tag}"

case "$ENVIRONMENT" in
  dev|qa|prod) ;;
  *) echo "Environment must be dev, qa or prod"; exit 1 ;;
esac

kubectl apply -n "$ENVIRONMENT" -f k8s/catalog-service.yaml
kubectl apply -n "$ENVIRONMENT" -f k8s/booking-service.yaml

sed "s|travel-catalog:v2|travel-catalog:$TAG|" \
  k8s/catalog-deployment.yaml |
  kubectl apply -n "$ENVIRONMENT" -f -

sed "s|travel-booking:v2|travel-booking:$TAG|" \
  k8s/booking-deployment.yaml |
  kubectl apply -n "$ENVIRONMENT" -f -

kubectl rollout status deployment/catalog \
  -n "$ENVIRONMENT" --timeout=180s

kubectl rollout status deployment/booking \
  -n "$ENVIRONMENT" --timeout=180s
