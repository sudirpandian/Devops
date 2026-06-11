pipeline {
    agent any

    environment {
        DOCKERHUB_USER = 'sudirpandian01'
        IMAGE_NAME     = 'trend-app'
        IMAGE_TAG      = "v${BUILD_NUMBER}"
        EKS_CLUSTER    = 'trend-eks'
        AWS_REGION     = 'ap-south-1'
        KUBECONFIG     = '/var/lib/jenkins/.kube/config'
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: 'project-2',
                    url: 'https://github.com/sudirpandian/Devops.git'
            }
        }

        stage('Docker Build') {
            steps {
                sh "docker build -t ${DOCKERHUB_USER}/${IMAGE_NAME}:${IMAGE_TAG} ."
                sh "docker tag ${DOCKERHUB_USER}/${IMAGE_NAME}:${IMAGE_TAG} ${DOCKERHUB_USER}/${IMAGE_NAME}:latest"
            }
        }

        stage('Docker Push') {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'dockerhub-creds',
                    usernameVariable: 'DOCKER_USER',
                    passwordVariable: 'DOCKER_PASS'
                )]) {
                    sh "echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin"
                    sh "docker push ${DOCKERHUB_USER}/${IMAGE_NAME}:${IMAGE_TAG}"
                    sh "docker push ${DOCKERHUB_USER}/${IMAGE_NAME}:latest"
                }
            }
        }

        stage('Deploy to EKS') {
            steps {
                sh "aws eks update-kubeconfig --region ${AWS_REGION} --name ${EKS_CLUSTER}"
                sh "kubectl set image deployment/trend-app trend-app=${DOCKERHUB_USER}/${IMAGE_NAME}:${IMAGE_TAG}"
                sh "kubectl rollout status deployment/trend-app"
            }
        }
    }

    post {
        success {
            echo 'Deployment successful!'
        }
        failure {
            echo 'Pipeline failed!'
        }
    }
}
