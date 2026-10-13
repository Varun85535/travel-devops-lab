#!/bin/bash
set -euo pipefail

TAG="${1:?Provide an image tag}"

kubectl apply -n dev -f k8s/catalog-service.yaml
kubectl apply -n dev -f k8s/booking-service.yaml

sed "s|travel-catalog:v2|travel-catalog:$TAG|" \
  k8s/catalog-deployment.yaml |
  kubectl apply -n dev -f -

sed "s|travel-booking:v2|travel-booking:$TAG|" \
  k8s/booking-deployment.yaml |
  kubectl apply -n dev -f -

kubectl rollout status deployment/catalog -n dev --timeout=180s
kubectl rollout status deployment/booking -n dev --timeout=180s
