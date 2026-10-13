pipeline {
    agent any

    stages {
        stage('Download code') {
            steps {
                git branch: 'main',
                    url: 'https://github.com/Varun85535/travel-devops-lab.git'
            }
        }

        stage('Build Docker images') {
            steps {
                sh 'docker build -t travel-catalog:v2 services/catalog'
                sh 'docker build -t travel-booking:v2 services/booking'
            }
        }

        stage('Push images to ECR') {
            steps {
                sh '''
                    set -e

                    REGISTRY=793790738267.dkr.ecr.ap-southeast-2.amazonaws.com

                    aws ecr get-login-password --region ap-southeast-2 |
                      docker login --username AWS --password-stdin "$REGISTRY"

                    for service in catalog booking
                    do
                        docker tag travel-$service:v2 "$REGISTRY/travel-$service:v2"
                        docker push "$REGISTRY/travel-$service:v2"
                    done
                '''
            }
        }

        stage('Deploy containers') {
            steps {
                sh '''
                    set -e

                    docker rm -f booking-v2 catalog-v2 || true

                    docker run -d \
                      --name catalog-v2 \
                      --network travel-network \
                      -p 8005:8000 \
                      travel-catalog:v2

                    docker run -d \
                      --name booking-v2 \
                      --network travel-network \
                      -p 8004:8001 \
                      -e CATALOG_URL=http://catalog-v2:8000 \
                      travel-booking:v2
                '''
            }
        }

        stage('Check application') {
            steps {
                sh '''
                    for attempt in 1 2 3 4 5 6 7 8 9 10
                    do
                        echo "Checking application: attempt $attempt"

                        if curl --fail --silent --show-error --max-time 5 \
                            http://localhost:8004/quote \
                            | python3 -c 'import json,sys; data=json.load(sys.stdin); assert data["destination"] == "Bengaluru"; assert data["price"] == 2500; print("Application check passed")'
                        then
                            exit 0
                        fi

                        sleep 2
                    done

                    echo "Application check failed after 10 attempts"
                    exit 1
                '''
            }
        }
    }
}

