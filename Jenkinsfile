pipeline {
    agent any

    environment {
        DOCKER_HUB_CREDENTIALS = credentials('DOCKER_HUB_TOKEN')  // your ID with DockerHub username/password or PAT
        DOCKER_HUB_REPO_BACKEND = 'sefali26/flask-prometheus-app'
        DOCKER_HUB_REPO_FRONTEND = 'sefali26/frontend-nginx'
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: 'CD-678', url: 'https://github.com/SefaliSabnam/aspect.git'
            }
        }

        stage('Build Backend Docker Image') {
            steps {
                bat '''
                    echo Building Backend Docker Image...
                    docker build -t %DOCKER_HUB_REPO_BACKEND%:latest -f backend/Dockerfile backend
                '''
            }
        }

        stage('Build Frontend Docker Image') {
            steps {
                bat '''
                    echo Building Frontend Docker Image...
                    docker build -t %DOCKER_HUB_REPO_FRONTEND%:latest -f frontend/Dockerfile frontend
                '''
            }
        }

        stage('Push to DockerHub') {
            steps {
                bat '''
                    echo Logging in to DockerHub...
                    echo %DOCKER_HUB_CREDENTIALS_PSW% | docker login -u %DOCKER_HUB_CREDENTIALS_USR% --password-stdin
                    echo Pushing Backend Image...
                    docker push %DOCKER_HUB_REPO_BACKEND%:latest
                    echo Pushing Frontend Image...
                    docker push %DOCKER_HUB_REPO_FRONTEND%:latest
                '''
            }
        }

        stage('Deploy to Minikube') {
            steps {
                bat '''
                    echo Deploying to Minikube...
                    kubectl apply -f k8s/
                '''
            }
        }
    }

    post {
        always {
            echo 'Cleaning up workspace...'
            deleteDir()
        }
        failure {
            echo 'Pipeline failed. Please check logs.'
        }
    }
}
