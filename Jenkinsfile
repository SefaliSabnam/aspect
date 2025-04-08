pipeline {
    agent any

    environment {
        DOCKERHUB_CREDENTIALS = credentials('dockerhub-credentials') // DockerHub creds
        GITHUB_TOKEN = credentials('github-token') // GitHub token
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm // checkout current branch being built
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
                bat '''
                echo Logging in to DockerHub...
                docker login -u %DOCKERHUB_CREDENTIALS_USR% -p %DOCKERHUB_CREDENTIALS_PSW%

                echo Pushing image...
                docker push sefali26/flask-prometheus-app:latest
                '''
            }
        }

        stage('Deploy to Minikube') {
            when {
                branch 'main' // Only deploy if branch is main (i.e., merged)
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
            echo 'Cleaning up...'
            deleteDir()
        }
        success {
            echo 'Pipeline completed successfully.'
        }
        failure {
            echo ' Pipeline failed.'
        }
    }
}
