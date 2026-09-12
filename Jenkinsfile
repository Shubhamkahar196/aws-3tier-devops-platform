pipeline {
    agent any

    environment {
        AWS_REGION     = 'ap-south-1'
        AWS_ACCOUNT_ID = '615299764407'

        ECR_REGISTRY = "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"

        FRONTEND_REPO = 'goal-tracker/frontend'
        BACKEND_REPO  = 'goal-tracker/backend'
    }

    stages {

        stage('Checkout') {
            steps {
                checkout scm

                script {
                    // Use the Git commit SHA as an immutable Docker tag
                    env.IMAGE_TAG = sh(
                        script: 'git rev-parse --short=12 HEAD',
                        returnStdout: true
                    ).trim()

                    echo "Building images with tag: ${env.IMAGE_TAG}"
                }
            }
        }

        stage('Build Frontend') {
            steps {
                sh '''
                    set -e

                    echo "Building frontend Docker image..."

                    docker build \
                      -t ${ECR_REGISTRY}/${FRONTEND_REPO}:${IMAGE_TAG} \
                      ./frontend
                '''
            }
        }

        stage('Build Backend') {
            steps {
                sh '''
                    set -e

                    echo "Building backend Docker image..."

                    docker build \
                      -t ${ECR_REGISTRY}/${BACKEND_REPO}:${IMAGE_TAG} \
                      ./backend
                '''
            }
        }

        stage('Trivy Security Scan') {
            steps {
                sh '''
                    set -e

                    echo "Scanning frontend image..."

                    trivy image \
                      --severity HIGH,CRITICAL \
                      --exit-code 1 \
                      ${ECR_REGISTRY}/${FRONTEND_REPO}:${IMAGE_TAG}

                    echo "Frontend scan passed."

                    echo "Scanning backend image..."

                    trivy image \
                      --severity HIGH,CRITICAL \
                      --exit-code 1 \
                      ${ECR_REGISTRY}/${BACKEND_REPO}:${IMAGE_TAG}

                    echo "Backend scan passed."
                '''
            }
        }

        stage('Login to ECR') {
            steps {
                sh '''
                    set -e

                    echo "Logging in to Amazon ECR..."

                    aws ecr get-login-password \
                      --region ${AWS_REGION} \
                    | docker login \
                      --username AWS \
                      --password-stdin ${ECR_REGISTRY}

                    echo "ECR login successful."
                '''
            }
        }

        stage('Push Images to ECR') {
            steps {
                sh '''
                    set -e

                    echo "Pushing frontend image..."

                    docker push \
                      ${ECR_REGISTRY}/${FRONTEND_REPO}:${IMAGE_TAG}

                    echo "Pushing backend image..."

                    docker push \
                      ${ECR_REGISTRY}/${BACKEND_REPO}:${IMAGE_TAG}

                    echo "Both images pushed successfully."
                '''
            }
        }
    }

    post {
        success {
            echo '========================================'
            echo 'CI PIPELINE COMPLETED SUCCESSFULLY'
            echo "Image tag: ${env.IMAGE_TAG}"
            echo '========================================'
        }

        failure {
            echo '========================================'
            echo 'CI PIPELINE FAILED'
            echo 'Check the failed stage above.'
            echo '========================================'
        }
    }
}