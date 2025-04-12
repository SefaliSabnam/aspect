pipeline {
    agent any

    environment {
        DOCKER_HUB_CREDENTIALS = credentials('DOCKER_HUB_TOKEN')
        DOCKER_HUB_REPO = 'sefali26/flask-prometheus-app'
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    echo "========================="
                    echo "Building Combined Flask App Docker Image..."
                    bat '''
                        docker build -t %DOCKER_HUB_REPO%:latest -f Dockerfile .
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
                        echo "Pushing Docker Image..."
                        docker push %DOCKER_HUB_REPO%:latest
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
                    echo "Ensuring Minikube is running using Docker driver..."
                    bat '''
                        minikube status | findstr "host: Running" >nul 2>&1
                        if errorlevel 1 (
                            echo "Minikube not running. Starting Minikube with docker driver..."
                            minikube start --driver=docker
                        ) else (
                            echo "Minikube is already running."
                        )
                    '''

                    echo "Setting kubectl context to minikube..."
                    bat 'kubectl config use-context minikube'

                    echo "Checking if Kubernetes API server is reachable..."
                    bat '''
                        for /f "tokens=* usebackq" %%i in (`kubectl get nodes ^| findstr "Ready"`) do (
                            echo "Cluster is Ready: %%i"
                        )
                    '''

                    echo "Deploying Kubernetes manifests..."
                    bat '''
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
