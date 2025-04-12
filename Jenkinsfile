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
                    echo "Checking if Minikube is running..."
                    // Check if Minikube is running, otherwise start it
                    bat '''
                        minikube status | findstr "host: Running" || (minikube start && echo "Minikube started.")
                    '''
                    echo "Setting kubectl context to minikube..."
                    // Set Kubernetes context to Minikube
                    bat '''
                        kubectl config use-context minikube
                    '''

                    echo "Checking Kubernetes Cluster Connection..."
                    // Check if Kubernetes is reachable
                    def clusterInfo = bat(script: 'kubectl cluster-info', returnStdout: true).trim()
                    if (clusterInfo.contains('Kubernetes master is running')) {
                        echo 'Kubernetes cluster is reachable.'
                    } else {
                        error 'Unable to reach Kubernetes cluster. Please check the setup.'
                    }

                    echo "Deploying Kubernetes manifests..."
                    // Deploy Kubernetes manifests
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
