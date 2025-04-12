pipeline {
    agent any

    environment {
        DOCKER_HUB_CREDENTIALS = credentials('DOCKER_HUB_TOKEN')
        DOCKER_HUB_REPO_BACKEND = 'sefali26/flask-prometheus-app'
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Build Docker Image') {
            steps {
                bat '''
                    echo =========================
                    echo Building Docker Image...
                    docker build -t %DOCKER_HUB_REPO_BACKEND%:latest -f Dockerfile .
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

                    echo Pushing Docker Image...
                    docker push %DOCKER_HUB_REPO_BACKEND%:latest
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
