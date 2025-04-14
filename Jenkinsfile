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
                    bat """
                        docker build -t %DOCKER_HUB_REPO%:latest -f Dockerfile .
                    """
                    echo "========================="
                }
            }
        }

        stage('Push to DockerHub') {
            steps {
                script {
                    echo "========================="
                    echo "Logging in to DockerHub..."
                    bat """
                        echo %DOCKER_HUB_CREDENTIALS_PSW% | docker login -u %DOCKER_HUB_CREDENTIALS_USR% --password-stdin
                        echo Pushing Docker Image...
                        docker push %DOCKER_HUB_REPO%:latest
                    """
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

                    bat "docker container prune -f"
                    bat "docker image prune -af"

                    bat """
                        minikube status | findstr "host: Running" >nul 2>&1
                        if errorlevel 1 (
                            echo Minikube not running. Starting...
                            minikube start --driver=docker --memory=4096 --cpus=2
                            timeout /t 20
                        ) else (
                            echo Minikube is already running.
                        )
                    """

                    bat """
                        kubectl config use-context minikube
                        if errorlevel 1 (
                            echo Failed to switch kubectl context. Exiting...
                            exit 1
                        )
                    """

                    echo "Waiting for Kubernetes API to respond..."

                    // Corrected loop for checking node readiness
                    bat """
                        for /L %%i in (1,1,10) do (
                            echo Checking node readiness (Attempt %%i)...
                            kubectl get nodes | findstr " Ready " && exit /b 0
                            timeout /t 5 >nul
                        )
                        echo Node not ready after multiple attempts. Exiting...
                        exit /b 1
                    """

                    bat """
                        echo Applying Kubernetes manifests...
                        kubectl apply --validate=false -f k8s/
                    """

                    echo "===== DEPLOYMENT COMPLETE ====="
                    echo "========================="
                }
            }
        }

        stage('Verify Application and Prometheus Metrics') {
            when {
                branch 'main'
            }
            steps {
                script {
                    echo "========================="
                    echo "Verifying application and Prometheus metrics..."

                    def minikubeIP = bat(script: 'minikube ip', returnStdout: true).trim().replaceAll("\r", "").replaceAll("\n", "")
                    echo "Minikube IP: ${minikubeIP}"

                    bat """
                        echo Checking if frontend is running...
                        curl -s http://${minikubeIP}:30001/ | findstr "Frontend Running"
                    """

                    bat """
                        echo Checking if backend is healthy...
                        curl -s http://${minikubeIP}:30002/api/health | findstr "OK"
                    """

                    bat """
                        echo Sending test POST to backend...
                        curl -X POST -H "Content-Type: application/json" ^
                        -d "{\\"name\\": \\"Item1\\", \\"description\\": \\"Description\\"}" ^
                        http://${minikubeIP}:30002/api/items
                    """

                    bat """
                        echo Checking if Prometheus metrics are exposed...
                        curl -s http://${minikubeIP}:30002/metrics | findstr "flask_app_database_query_count_total"
                    """

                    echo "========================="
                    echo "To access Grafana manually, open in your browser:"
                    echo "➡ http://${minikubeIP}:30003"
                    echo "Default credentials: admin / admin"
                    echo "Navigate to Dashboards > Browse > Prometheus Dashboard"
                    echo "========================="

                    echo "Deployment Successful: Application and monitoring are working!"
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
        success {
            echo 'The project was successfully deployed!'
        }
    }
}
