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
                    echo "===== STARTING: Minikube Cluster & Deployment ====="

                    bat '''
                        echo Cleaning up unused Docker containers/images...
                        docker container prune -f
                        docker image prune -af

                        echo Checking Minikube status...
                        minikube status | findstr "host: Running" >nul 2>&1
                        if errorlevel 1 (
                            echo "Minikube not running. Starting Minikube with Docker driver..."
                            minikube start --driver=docker --memory=4096 --cpus=2
                        ) else (
                            echo "Minikube is already running."
                        )
                    '''

                    echo "Setting kubectl context to Minikube..."
                    bat '''
                        kubectl config use-context minikube
                        if errorlevel 1 (
                            echo Failed to switch kubectl context. Exiting...
                            exit 1
                        )
                    '''

                    echo "Waiting for Kubernetes API to be ready..."
                    bat '''
                        timeout /t 10
                        echo Checking node readiness...
                        for /f "tokens=* usebackq" %%i in (`kubectl get nodes ^| findstr "Ready"`) do (
                            echo "Cluster is Ready: %%i"
                        )
                    '''

                    echo "Deploying Kubernetes manifests..."
                    bat '''
                        kubectl apply --validate=false -f k8s/
                    '''

                    echo "===== DEPLOYMENT COMPLETE ====="
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
