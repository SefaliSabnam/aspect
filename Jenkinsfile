pipeline {
    agent any

    environment {
        DOCKER_CRED = credentials('DOCKER_HUB_TOKEN') // DockerHub: Username + Password
        GITHUB_TOKEN = credentials('github-token')    // GitHub token (if needed)
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm // Checkout whatever branch triggered the pipeline
            }
        }

        stage('Build Docker Image') {
            steps {
                bat '''
                echo Building Docker image...
                docker build -t sefali26/flask-prometheus-app:latest -f Dockerfile .
                '''
            }
        }

        stage('Push to DockerHub') {
            steps {
                bat """
                echo Logging in to DockerHub...
                docker login -u ${DOCKER_CRED_USR} -p ${DOCKER_CRED_PSW}

                echo Pushing Docker image...
                docker push sefali26/flask-prometheus-app:latest
                """
            }
        }

        stage('Deploy to Minikube') {
            when {
                branch 'main' // Only deploy when on main branch
            }
            steps {
                bat '''
                echo Setting KUBECONFIG...
                SET KUBECONFIG=%USERPROFILE%\\.kube\\config

                echo Deploying to Minikube...
                kubectl apply -f k8s/
                '''
            }
        }
    }

    post {
        always {
            script {
                echo 'Cleaning up workspace...'
                deleteDir()
            }
        }
        success {
            echo ' Pipeline finished successfully!'
        }
        failure {
            echo ' Pipeline failed. Please check logs.'
        }
    }
}
