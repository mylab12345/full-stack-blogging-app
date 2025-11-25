pipeline {
    agent any

    environment {
        // Replace 'mekdb1' with your actual Docker Hub username
        IMAGE = "docker.io/mydockerkdb/blog-app:latest"
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
                // Compile and package the Java project
                sh 'mvn clean package'
            }
        }

        stage('SonarQube Analysis') {
            steps {
                // Run SonarQube analysis using Maven plugin
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
                    // Build Docker image tagged with Docker Hub path
                    sh "docker build -t ${IMAGE} ."
                }
            }
        }

        stage('Push to Docker Hub') {
            steps {
                // Use Jenkins credentials to log in and push
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
