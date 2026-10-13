pipeline {
    agent any

    options {
        skipDefaultCheckout()
        disableConcurrentBuilds()
    }

    environment {
        AWS_REGION = 'ap-southeast-2'
        REGISTRY = '793790738267.dkr.ecr.ap-southeast-2.amazonaws.com'
    }

    stages {
        stage('Download code') {
            steps {
                checkout scm
            }
        }

        stage('Build Docker images') {
            steps {
                sh '''
                    set -e

                    docker build \
                      -t "$REGISTRY/travel-catalog:$BUILD_NUMBER" \
                      services/catalog

                    docker build \
                      -t "$REGISTRY/travel-booking:$BUILD_NUMBER" \
                      services/booking
                '''
            }
        }

        stage('Push images to ECR') {
            steps {
                sh '''#!/bin/bash
                    set -euo pipefail

                    aws ecr get-login-password --region "$AWS_REGION" |
                      docker login --username AWS --password-stdin "$REGISTRY"

                    docker push "$REGISTRY/travel-catalog:$BUILD_NUMBER"
                    docker push "$REGISTRY/travel-booking:$BUILD_NUMBER"
                '''
            }
        }

        stage('Deploy to DEV EKS') {
            steps {
                sh '''
                    set -e

                    aws eks update-kubeconfig \
                      --region "$AWS_REGION" \
                      --name travel-eks

                    bash scripts/deploy-dev.sh "$BUILD_NUMBER"
                '''
            }
        }

        stage('Check DEV application') {
            steps {
                sh '''
                    for attempt in 1 2 3 4 5
                    do
                        echo "Checking DEV: attempt $attempt"

                        if kubectl exec -n dev deployment/booking -- \
                          python -c 'import json; from urllib.request import urlopen; data=json.load(urlopen("http://localhost:8001/quote", timeout=5)); assert data["destination"] == "Bengaluru"; assert data["price"] == 2500; print("DEV application check passed")'
                        then
                            exit 0
                        fi

                        sleep 2
                    done

                    echo "DEV application check failed"
                    exit 1
                '''
            }
        }
    }
}
