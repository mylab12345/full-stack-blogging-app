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
                sh 'docker build -t $IMAGE .'
            }
        }

        stage('Trivy Scan') {
            steps {
                sh '''
                docker run --rm \
                  -v /var/run/docker.sock:/var/run/docker.sock \
                  aquasec/trivy:latest image \
                  --exit-code 1 --severity HIGH,CRITICAL \
                  $IMAGE
                '''
            }
        }

        stage('SonarQube Analysis') {
            steps {
                withSonarQubeEnv("${SONARQUBE_ENV}") {
                    sh 'sonar-scanner || true'
                }
            }
        }

        stage('Push to Registry') {
            steps {
                sh 'docker push $IMAGE || true'
            }
        }
    }

    post {
        always {
            echo "Pipeline finished. Check SonarQube dashboard and Trivy scan results."
        }
    }
}
