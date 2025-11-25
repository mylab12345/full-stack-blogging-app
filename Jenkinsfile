pipeline {
    agent any

    environment {
        IMAGE = "docker.io/mydockerkdb/blog-app:latest"
        SONARQUBE_ENV = "local-sonar"
        KUBECONFIG = "/etc/rancher/k3s/k3s.yaml"
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
                sh "docker build -t ${IMAGE} ."
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

        stage('Trivy Scan') {
            steps {
                sh "trivy image ${IMAGE}"
            }
        }

        stage('Deploy to k3s') {
            steps {
                script {
                    // Apply Kubernetes manifests to k3s
                    sh '''
                    export KUBECONFIG=${KUBECONFIG}
                    kubectl apply -f k8s/deployment.yaml
                    kubectl apply -f k8s/service.yaml
                    kubectl rollout status deployment/blog-app
                    '''
                }
            }
        }

        stage('Smoke Test') {
            steps {
                // Replace with your service NodePort or Ingress URL
                sh 'curl -f http://localhost:30080 || exit 1'
            }
        }
    }

    post {
        always {
            echo "Pipeline finished. Blog app deployed to k3s. Check SonarQube, Nexus, and Trivy results."
        }
    }
}
