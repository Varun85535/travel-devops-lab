#!/bin/bash
set -euo pipefail

ENVIRONMENT="${1:?Provide dev, qa or prod}"

case "$ENVIRONMENT" in
  dev|qa|prod) ;;
  *) echo "Environment must be dev, qa or prod"; exit 1 ;;
esac

for attempt in 1 2 3 4 5
do
    echo "Checking $ENVIRONMENT: attempt $attempt"

    if kubectl exec -n "$ENVIRONMENT" deployment/booking -- \
      python -c 'import json; from urllib.request import urlopen; data=json.load(urlopen("http://localhost:8001/quote", timeout=5)); assert data["destination"] == "Bengaluru"; assert data["price"] == 2500; print("Application check passed")'
    then
        exit 0
    fi

    sleep 2
done

echo "Application check failed"
exit 1
