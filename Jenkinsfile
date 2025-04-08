pipeline {
    agent any

    environment {
        DOCKER_HUB_REPO = 'sefali26/flask-prometheus-app'
    }

    stages {
        stage('Checkout') {
            when {
                branch 'main'
            }
            steps {
                checkout scm
            }
        }

        stage('Build Docker Images') {
            when {
                branch 'main'
            }
            steps {
                sh 'docker build -t $DOCKER_HUB_REPO ./backend'
                sh 'docker build -t sefali26/frontend-nginx ./frontend'
            }
        }

        stage('Push to DockerHub') {
            when {
                branch 'main'
            }
            steps {
                withCredentials([string(credentialsId: 'docker-hub-token', variable: 'DOCKER_TOKEN')]) {
                    sh 'echo $DOCKER_TOKEN | docker login -u sefali26 --password-stdin'
                    sh 'docker push $DOCKER_HUB_REPO'
                    sh 'docker push sefali26/frontend-nginx'
                }
            }
        }

        stage('Deploy to Minikube') {
            when {
                allOf {
                    branch 'main'
                    expression { return env.CHANGE_ID == null }
                }
            }
            steps {
                sh 'kubectl apply -f k8s/'
            }
        }
    }
}
