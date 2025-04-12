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
                        echo Waiting for 10 seconds...
                        ping -n 10 127.0.0.1 >nul
                    '''

                    echo "Checking node readiness..."
                    bat '''
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

        stage('Verify Application and Grafana Metrics') {
            steps {
                script {
                    echo "========================="
                    echo "Verifying application and Grafana metrics..."

                    // Get Minikube IP
                    def minikubeIP = bat(script: 'minikube ip', returnStdout: true).trim().replaceAll("\r", "").replaceAll("\n", "")
                    echo "Minikube IP: ${minikubeIP}"

                    // Check if frontend is running
                    bat """
                        echo Checking if frontend is running...
                        curl -s http://${minikubeIP}:30001/ | findstr "Frontend Running"
                    """

                    // Check if backend is healthy
                    bat """
                        echo Checking if backend is healthy...
                        curl -s http://${minikubeIP}:30002/api/health | findstr "OK"
                    """

                    // Perform a sample POST request to backend
                    bat """
                        echo Sending test POST to backend...
                        curl -X POST -H "Content-Type: application/json" -d "{\\"name\\": \\"Item1\\", \\"description\\": \\"Description\\"}" http://${minikubeIP}:30002/api/items
                    """

                    // Optional: Check Prometheus metric exposed by Flask
                    bat """
                        echo Checking if Prometheus metrics are exposed...
                        curl -s http://${minikubeIP}:30002/metrics | findstr "flask_app_database_query_count_total"
                    """

                    // Query Grafana (if API token is set correctly)
                    bat """
                        echo Querying Grafana for metric data...
                        curl -G -s -H "Authorization: Bearer <grafana-api-token>" ^
                        "http://${minikubeIP}:30003/api/datasources/proxy/1/api/v1/query" ^
                        --data-urlencode "query=flask_app_database_query_count_total"
                    """

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
