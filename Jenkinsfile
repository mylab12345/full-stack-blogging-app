pipeline {
    agent any

    environment {
        IMAGE = "docker.io/<your-dockerhub-username>/blog-app:latest"
        SONARQUBE_ENV = "local-sonar"
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Build with Maven') {
            steps {
                sh 'mvn clean package'
            }
        }

        stage('SonarQube Analysis') {
            steps {
                withSonarQubeEnv("${SONARQUBE_ENV}") {
                    withCredentials([string(credentialsId: 'sonar-token', variable: 'SONARQUBE_TOKEN')]) {
                        sh '''
                        mvn sonar:sonar \
                          -Dsonar.projectKey=blog-app \
                          -Dsonar.host.url=http://localhost:9000 \
                          -Dsonar.login=$SONARQUBE_TOKEN
                        '''
                    }
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    sh "docker build -t ${IMAGE} ."
                }
            }
        }

        stage('Push to Docker Hub') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'docker-creds', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                    sh '''
                    echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin
                    docker push ${IMAGE}
                    '''
                }
            }
        }
    }

    post {
        always {
            echo "Pipeline finished. Check SonarQube dashboard and Docker Hub image."
        }
    }
}
