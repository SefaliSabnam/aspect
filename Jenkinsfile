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
                bat '''
                    echo =========================
                    echo Building Backend Docker Image...
                    docker build -t %DOCKER_HUB_REPO_BACKEND%:latest -f Dockerfile .
                    echo =========================
                '''
            }
        }

        stage('Build Frontend Docker Image') {
            steps {
                bat '''
                    echo =========================
                    echo Building Frontend Docker Image...
                    docker build -t %DOCKER_HUB_REPO_FRONTEND%:latest -f frontend/Dockerfile frontend
                    echo =========================
                '''
            }
        }

        stage('Push to DockerHub') {
            steps {
                bat '''
                    echo =========================
                    echo Logging in to DockerHub...
                    docker login -u %DOCKER_HUB_CREDENTIALS_USR% -p %DOCKER_HUB_CREDENTIALS_PSW%

                    echo Pushing Backend Image...
                    docker push %DOCKER_HUB_REPO_BACKEND%:latest

                    echo Pushing Frontend Image...
                    docker push %DOCKER_HUB_REPO_FRONTEND%:latest
                    echo =========================
                '''
            }
        }

        stage('Deploy to Minikube') {
            when {
                branch 'main'
            }
            steps {
                bat '''
                    echo =========================
                    echo Checking Kubernetes context...
                    kubectl config current-context

                    echo Deploying to Minikube...
                    kubectl apply -f k8s/
                    echo =========================
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
            echo 'Pipeline failed. Check the logs.'
        }
    }
}
