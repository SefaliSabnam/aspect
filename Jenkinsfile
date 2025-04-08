pipeline {
    agent any

    environment {
        GITHUB_CREDENTIALS = credentials('github-token') // GitHub token only
        DOCKER_HUB_CREDENTIALS = credentials('DOCKER_HUB_TOKEN')
        DOCKER_HUB_REPO = 'sefali26/flask-prometheus-app'
    }

    stages {
        stage('Checkout') {
            steps {
                checkout([
                    $class: 'GitSCM',
                    userRemoteConfigs: [[
                        credentialsId: 'github-token',
                        url: 'https://github.com/${env.GIT_REPO}'
                    ]],
                    branches: [[name: "${env.BRANCH_NAME}"]]
                ])
            }
        }

        stage('Build Docker Image') {
            steps {
                bat '''
                    echo Building unified backend + frontend Docker image...
                    docker build -t %DOCKER_HUB_REPO%:latest .
                '''
            }
        }

        stage('Push to DockerHub') {
            steps {
                bat '''
                    echo Logging in to DockerHub...
                    echo %DOCKER_HUB_CREDENTIALS_PSW% | docker login -u %DOCKER_HUB_CREDENTIALS_USR% --password-stdin
                    docker push %DOCKER_HUB_REPO%:latest
                '''
            }
        }

        stage('Deploy to Minikube') {
            when {
                branch 'main'
            }
            steps {
                bat '''
                    echo Deploying to Minikube only on main branch...
                    kubectl apply -f k8s/
                '''
            }
        }
    }

    post {
        always {
            echo 'Cleaning up workspace...'
            deleteDir()
        }
        failure {
            echo 'Pipeline failed. Check the logs above.'
        }
    }
}
