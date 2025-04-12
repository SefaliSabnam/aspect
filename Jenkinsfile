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

                    // Get Minikube IP and log it
                    echo "Getting Minikube IP..."
                    def minikubeIP = bat(script: 'minikube ip', returnStdout: true).trim()
                    echo "Minikube IP: ${minikubeIP}"

                    // Check if the frontend is up
                    echo "Checking if frontend is up..."
                    def frontendPort = 30001  // Replace with actual frontend node port
                    bat '''
                        curl -s http://%minikubeIP%:%frontendPort%/ | findstr "Frontend Running"
                    '''
                    
                    // Check if the backend is up
                    echo "Checking if backend is up..."
                    def backendPort = 30002  // Replace with actual backend node port
                    bat '''
                        curl -s http://%minikubeIP%:%backendPort%/api/health | findstr "OK"
                    '''
                    
                    // Perform a sample CRUD operation: POST request to the backend API
                    echo "Performing sample POST request to backend API..."
                    bat '''
                        curl -X POST -H "Content-Type: application/json" -d "{\"name\": \"Item1\", \"description\": \"Description of item1\"}" http://%minikubeIP%:%backendPort%/api/items
                    '''
                    
                    // Query Grafana for metrics (ensure the correct Grafana API token is set)
                    echo "Querying Grafana for metrics..."
                    def grafanaPort = 30003  // Replace with actual Grafana node port
                    bat '''
                        curl -G -s -H "Authorization: Bearer <grafana-api-token>" "http://%minikubeIP%:%grafanaPort%/api/datasources/proxy/1/api/v1/query" --data-urlencode "query=flask_app_database_query_count_total"
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
