pipeline {

    agent any

    environment {
        AWS_REGION     = 'ap-south-1'
        AWS_ACCOUNT_ID = '615299764407'

        ECR_REGISTRY = "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"

        FRONTEND_REPO = 'goal-tracker/frontend'
        BACKEND_REPO  = 'goal-tracker/backend'

        DOCKERHUB_USERNAME = 'shubhamkah'

        DOCKERHUB_FRONTEND = "${DOCKERHUB_USERNAME}/goal-tracker-frontend:1.0"
        DOCKERHUB_BACKEND  = "${DOCKERHUB_USERNAME}/goal-tracker-backend:1.0"
    }

    stages {

        stage('Checkout') {
            steps {
                checkout scm

                script {
                    // Use Git commit SHA as immutable Docker tag
                    env.IMAGE_TAG = sh(
                        script: 'git rev-parse --short=12 HEAD',
                        returnStdout: true
                    ).trim()

                    echo "Using image tag: ${env.IMAGE_TAG}"
                }
            }
        }

        stage('Pull Images from Docker Hub') {
            steps {
                sh '''
                    set -e

                    echo "Pulling frontend image from Docker Hub..."
                    docker pull ${DOCKERHUB_FRONTEND}

                    echo "Pulling backend image from Docker Hub..."
                    docker pull ${DOCKERHUB_BACKEND}

                    echo "Docker Hub images pulled successfully."
                '''
            }
        }

        stage('Tag Images for ECR') {
            steps {
                sh '''
                    set -e

                    echo "Tagging frontend image for ECR..."

                    docker tag \
                      ${DOCKERHUB_FRONTEND} \
                      ${ECR_REGISTRY}/${FRONTEND_REPO}:${IMAGE_TAG}

                    echo "Tagging backend image for ECR..."

                    docker tag \
                      ${DOCKERHUB_BACKEND} \
                      ${ECR_REGISTRY}/${BACKEND_REPO}:${IMAGE_TAG}

                    echo "Images tagged successfully."
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