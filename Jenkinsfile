pipeline {
    agent any

    environment {
        DOCKER_HUB_CREDENTIALS = credentials('DOCKER_HUB_TOKEN')
        DOCKER_HUB_REPO_BACKEND = 'sefali26/flask-prometheus-app'
        DOCKER_HUB_REPO_FRONTEND = 'sefali26/frontend-nginx'
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Build Backend Docker Image') {
            steps {
                script {
                    echo "========================="
                    echo "Building Backend Docker Image..."
                    bat '''
                        docker build -t %DOCKER_HUB_REPO_BACKEND%:latest -f Dockerfile .
                    '''
                    echo "========================="
                }
            }
        }

        stage('Build Frontend Docker Image') {
            steps {
                script {
                    echo "========================="
                    echo "Building Frontend Docker Image..."
                    bat '''
                        docker build -t %DOCKER_HUB_REPO_FRONTEND%:latest -f frontend/Dockerfile frontend
                    '''
                    echo "========================="
                }
            }
        }

        stage('Push to DockerHub') {
            steps {
                script {
                    echo "========================="
                    echo "Logging in to DockerHub..."
                    bat '''
                        echo %DOCKER_HUB_CREDENTIALS_PSW% | docker login -u %DOCKER_HUB_CREDENTIALS_USR% --password-stdin
                        echo "Pushing Backend Image..."
                        docker push %DOCKER_HUB_REPO_BACKEND%:latest
                        echo "Pushing Frontend Image..."
                        docker push %DOCKER_HUB_REPO_FRONTEND%:latest
                    '''
                    echo "========================="
                }
            }
        }

        stage('Start Minikube & Deploy') {
            when {
                branch 'main'
            }
            steps {
                script {
                    echo "========================="
                    echo "Checking if Minikube is running..."
                    bat '''
                        minikube status | findstr "host: Running" || (minikube start && echo "Minikube started.")
                    '''
                    echo "Setting kubectl context to minikube..."
                    bat '''
                        kubectl config use-context minikube
                        echo "Deploying Kubernetes manifests..."
                        kubectl apply --validate=false -f k8s/
                    '''
                    echo "========================="
                }
            }
        }
    }

    post {
        always {
            echo 'Cleaning up workspace...'
            cleanWs()
        }
        failure {
            echo 'Pipeline failed. Check the logs.'
        }
    }
}
