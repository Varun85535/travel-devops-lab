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

        stage('Connect to EKS') {
            steps {
                sh '''
                    aws eks update-kubeconfig \
                      --region "$AWS_REGION" \
                      --name travel-eks
                '''
            }
        }

        stage('Deploy and check DEV') {
            steps {
                sh 'bash scripts/deploy.sh dev "$BUILD_NUMBER"'
                sh 'bash scripts/check.sh dev'
            }
        }

        stage('Approve QA') {
            steps {
                timeout(time: 30, unit: 'MINUTES') {
                    input message: 'DEV passed. Deploy to QA?'
                }
            }
        }

        stage('Deploy and check QA') {
            steps {
                sh 'bash scripts/deploy.sh qa "$BUILD_NUMBER"'
                sh 'bash scripts/check.sh qa'
            }
        }

        stage('Approve PROD') {
            steps {
                timeout(time: 30, unit: 'MINUTES') {
                    input message: 'QA passed. Deploy to PROD?'
                }
            }
        }

        stage('Deploy and check PROD') {
            steps {
                sh 'bash scripts/deploy.sh prod "$BUILD_NUMBER"'
                sh 'bash scripts/check.sh prod'
            }
        }
    }
}
