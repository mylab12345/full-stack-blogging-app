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
                // Run Trivy in Docker, save report, but don't fail pipeline
                sh '''
                docker run --rm \
                  -v /var/run/docker.sock:/var/run/docker.sock \
                  aquasec/trivy:latest image \
                  --exit-code 0 --severity HIGH,CRITICAL \
                  --format table \
                  $IMAGE > trivy-report.txt
                '''
            }
        }

        stage('SonarQube Analysis') {
            steps {
                withSonarQubeEnv("${SONARQUBE_ENV}") {
                    sh '''
                    sonar-scanner \
                      -Dsonar.projectKey=blog-app \
                      -Dsonar.sources=. \
                      -Dsonar.host.url=http://localhost:9000 \
                      -Dsonar.login=$SONARQUBE_TOKEN || true
                    '''
                }
            }
        }

        stage('Push to Registry') {
            steps {
                sh '''
                docker login localhost:5000 -u admin -p admin123 || true
                docker push $IMAGE || true
                '''
            }
        }
    }

    post {
        always {
            echo "Pipeline finished. Check SonarQube dashboard, Trivy report, and registry image."
        }
    }
}
