pipeline {
    agent any

    environment {
        DOCKER_CREDS   = credentials('docker')
        GIT_SHA        = sh(script: 'git rev-parse --short HEAD', returnStdout: true).trim()
        TIMESTAMP      = sh(script: 'date +%Y%m%d%H%M%S', returnStdout: true).trim()
        CONTAINER_NAME = 'react-app'
    }

    options {
        buildDiscarder(logRotator(numToKeepStr: '10'))
        timeout(time: 30, unit: 'MINUTES')
        disableConcurrentBuilds()
    }

    stages {
        stage('Checkout') {
            steps {
                echo "Branch: ${env.BRANCH_NAME} | Commit: ${GIT_SHA}"
                checkout scm
            }
        }

        stage('Set Image Variables') {
            steps {
                script {
                    if (env.BRANCH_NAME == 'project-3-master') {
                        env.REPO         = "${env.DOCKER_CREDS_USR}/prod"
                        env.IMAGE_TAG    = "prod-${GIT_SHA}-${TIMESTAMP}"
                        env.ENV_NAME     = 'production'
                    } else {
                        env.REPO         = "${env.DOCKER_CREDS_USR}/dev"
                        env.IMAGE_TAG    = "dev-${GIT_SHA}-${TIMESTAMP}"
                        env.ENV_NAME     = 'development'
                    }
                    env.FULL_IMAGE   = "${env.REPO}:${env.IMAGE_TAG}"
                    env.LATEST_IMAGE = "${env.REPO}:latest"
                    echo "Target image: ${env.FULL_IMAGE}"
                }
            }
        }

        stage('Docker Build') {
            steps {
                echo "Building Docker image: ${env.FULL_IMAGE}"
                sh """
                    docker build \
                        -t ${env.FULL_IMAGE} \
                        -t ${env.LATEST_IMAGE} \
                        .
                """
            }
        }

        stage('Docker Push') {
            steps {
                echo "Pushing to Docker Hub..."
                sh """
                    echo \$DOCKER_CREDS_PSW | docker login -u \$DOCKER_CREDS_USR --password-stdin
                    docker push ${env.FULL_IMAGE}
                    docker push ${env.LATEST_IMAGE}
                    docker logout
                """
            }
        }

        stage('Deploy') {
            steps {
                sh """
                    chmod +x deploy.sh
                    ./deploy.sh ${env.FULL_IMAGE}
                """
            }
        }

        stage('Health Check') {
            steps {
                sh """
                    sleep 10
                    curl -sf http://localhost:80/health || \
                      (echo 'Health check failed!' && docker logs ${CONTAINER_NAME} --tail=50 && exit 1)
                    echo 'Application is healthy!'
                """
            }
        }
    }

    post {
        success {
            echo "SUCCESS | Branch: ${env.BRANCH_NAME} | Image: ${env.FULL_IMAGE}"
        }
        failure {
            echo "FAILED | Branch: ${env.BRANCH_NAME}"
        }
    }
}
