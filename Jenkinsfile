pipeline {
    agent any

    environment {
        IMAGE = "localhost:5000/blog-app:latest"
        SONARQUBE_ENV = "local-sonar"
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
                    // Build image using Docker CLI
                    sh "docker build -t ${IMAGE} ."
                }
            }
        }

        stage('SonarQube Analysis') {
            steps {
                withSonarQubeEnv("${SONARQUBE_ENV}") {
                    withCredentials([string(credentialsId: 'sonar-token', variable: 'SONARQUBE_TOKEN')]) {
                        sh """
                        sonar-scanner \
                          -Dsonar.projectKey=blog-app \
                          -Dsonar.sources=. \
                          -Dsonar.host.url=http://sonarqube:9000 \
                          -Dsonar.login=${SONARQUBE_TOKEN} || true
                        """
                    }
                }
            }
        }

        stage('Push to Registry') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'docker-creds', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                    sh """
                    docker login localhost:5000 -u ${DOCKER_USER} -p ${DOCKER_PASS}
                    docker push ${IMAGE}
                    """
                }
            }
        }
    }

    post {
        always {
            echo "Pipeline finished. Check SonarQube dashboard and registry image."
        }
    }
}
