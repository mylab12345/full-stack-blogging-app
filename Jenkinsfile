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

        stage('Deploy to k3s') {
            steps {
                script {
                    sh '''
                    export KUBECONFIG=${KUBECONFIG}
                    kubectl apply -f deployment.yaml
                    kubectl apply -f service.yml
                    kubectl rollout status deployment/blog-app
                    '''
                }
            }
        }

        stage('Smoke Test') {
            steps {
                // Adjust port if your service.yaml uses a different NodePort
                sh 'curl -f http://localhost:30080 || exit 1'
            }
        }
    }

    post {
        always {
            echo "Pipeline finished. Blog app deployed to k3s. Check SonarQube and Nexus dashboards."
        }
    }
}
