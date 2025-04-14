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

                    // Clean Docker containers and images
                    bat """
                        docker container prune -f
                        docker image prune -af
                    """

                    // Check if Minikube is running, start if not
                    bat """
                        minikube status | findstr "host: Running" >nul 2>&1
                        if errorlevel 1 (
                            echo "Minikube not running. Starting..."
                            minikube start --driver=docker --memory=4096 --cpus=2
                        ) else (
                            echo "Minikube is already running."
                        )
                    """

                    // Ensure Minikube can access the registry (proxy configuration)
                    bat """
                        set HTTP_PROXY=http://your.proxy.address:port
                        set HTTPS_PROXY=http://your.proxy.address:port
                    """

                    // Switch to Minikube context for kubectl
                    bat """
                        kubectl config use-context minikube
                        if errorlevel 1 (
                            echo Failed to switch kubectl context. Exiting...
                            exit 1
                        )
                    """

                    // Wait for Kubernetes API to be ready
                    bat """
                        echo Waiting for Kubernetes API...
                        ping -n 10 127.0.0.1 >nul
                    """

                    // Check node readiness
                    bat """
                        echo Checking node readiness...
                        kubectl get nodes | findstr "Ready"
                    """

                    // Apply Kubernetes manifests
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

                    // Get Minikube IP
                    def minikubeIP = bat(script: 'minikube ip', returnStdout: true).trim().replaceAll("\r", "").replaceAll("\n", "")
                    echo "Minikube IP: ${minikubeIP}"

                    // Verify frontend is running
                    bat """
                        echo Checking if frontend is running...
                        curl -s http://${minikubeIP}:30001/ | findstr "Frontend Running"
                    """

                    // Verify backend health
                    bat """
                        echo Checking if backend is healthy...
                        curl -s http://${minikubeIP}:30002/api/health | findstr "OK"
                    """

                    // Send test POST to backend
                    bat """
                        echo Sending test POST to backend...
                        curl -X POST -H "Content-Type: application/json" ^
                        -d "{\\"name\\": \\"Item1\\", \\"description\\": \\"Description\\"}" ^
                        http://${minikubeIP}:30002/api/items
                    """

                    // Verify Prometheus metrics
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
