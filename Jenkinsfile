pipeline {
    agent any

    environment {
        REGISTRY = "localhost:5000"
        IMAGE = "${REGISTRY}/blog-app:latest"
        SONARQUBE_ENV = "local-sonar"   // name of your SonarQube server config in Jenkins
        SONARQUBE_PROJECT_KEY = "blog-app"
        SONARQUBE_TOKEN = credentials('sonar-token') // Jenkins credential ID for SonarQube token
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Build Docker Image') {
            steps {
                sh "docker build -t ${IMAGE} ."
            }
        }

        stage('Trivy Scan') {
            steps {
                // Fail build if HIGH or CRITICAL vulnerabilities are found
                sh "trivy image --exit-code 1 --severity HIGH,CRITICAL --format table --output trivy-report.txt ${IMAGE}"
                archiveArtifacts artifacts: 'trivy-report.txt', fingerprint: true
            }
        }

        stage('SonarQube Analysis') {
            steps {
                withSonarQubeEnv("${SONARQUBE_ENV}") {
                    sh """
                        sonar-scanner \
                          -Dsonar.projectKey=${SONARQUBE_PROJECT_KEY} \
                          -Dsonar.sources=. \
                          -Dsonar.host.url=${SONAR_HOST_URL} \
                          -Dsonar.login=${SONARQUBE_TOKEN}
                    """
                }
            }
        }

        stage('Push to Registry') {
            steps {
                sh "docker push ${IMAGE}"
            }
        }
    }

    post {
        always {
            echo "Pipeline finished. Check SonarQube dashboard and Trivy report artifacts."
        }
    }
}
