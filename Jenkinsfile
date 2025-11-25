pipeline {
    agent any

    environment {
        // Replace 'mekdb1' with your actual Docker Hub username
        IMAGE = "docker.io/mydockerkdb/blog-app:latest"
        SONARQUBE_ENV = "local-sonar"
        // Path to kubeconfig copied for Jenkins user
        KUBECONFIG = "/var/lib/jenkins/k3s.yaml"
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

        stage('Deploy to k3s') {
            steps {
                script {
                    sh '''
                    export KUBECONFIG=${KUBECONFIG}
                    kubectl apply -f k8s/deployment.yaml
                    '''
                }
            }
        }

        stage('Smoke Test') {
            steps {
                script {
                    sh '''
                    export KUBECONFIG=${KUBECONFIG}
                    kubectl rollout status deployment/blog-app
                    kubectl get pods -l app=blog-app
                    '''
                }
            }
        }
    }

    post {
        always {
            echo "Pipeline finished. Blog app deployed to k3s. Check SonarQube dashboard, Docker Hub image, and rollout status."
        }
    }
}
