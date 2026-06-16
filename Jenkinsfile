// =============================================================
// Jenkinsfile — CI/CD Pipeline for devops-build React App
// Triggers: dev branch  → build + push to Docker Hub /dev repo
//           master branch → build + push to Docker Hub /prod repo
// =============================================================

pipeline {
    agent any

    environment {
        DOCKER_USER       = credentials('DOCKER_HUB_USERNAME')
        DOCKER_PASS       = credentials('DOCKER_HUB_PASSWORD')
        GIT_SHA           = sh(script: 'git rev-parse --short HEAD', returnStdout: true).trim()
        TIMESTAMP         = sh(script: 'date +%Y%m%d%H%M%S', returnStdout: true).trim()
        APP_PORT          = '80'
        CONTAINER_NAME    = 'react-app'
    }

    options {
        buildDiscarder(logRotator(numToKeepStr: '10'))
        timeout(time: 30, unit: 'MINUTES')
        disableConcurrentBuilds()
    }

    stages {

        // --------------------------------------------------
        stage('Checkout') {
            steps {
                echo "Branch: ${env.BRANCH_NAME} | Commit: ${GIT_SHA}"
                checkout scm
            }
        }

        // --------------------------------------------------
        stage('Set Image Variables') {
            steps {
                script {
                    if (env.BRANCH_NAME == 'master' || env.BRANCH_NAME == 'main') {
                        env.REPO        = "${DOCKER_USER}/prod"
                        env.IMAGE_TAG   = "prod-${GIT_SHA}-${TIMESTAMP}"
                        env.ENV_NAME    = 'production'
                    } else {
                        env.REPO        = "${DOCKER_USER}/dev"
                        env.IMAGE_TAG   = "dev-${GIT_SHA}-${TIMESTAMP}"
                        env.ENV_NAME    = 'development'
                    }
                    env.FULL_IMAGE  = "${env.REPO}:${env.IMAGE_TAG}"
                    env.LATEST_IMAGE = "${env.REPO}:latest"
                    echo "Target image: ${env.FULL_IMAGE}"
                }
            }
        }

        // --------------------------------------------------
        stage('Docker Build') {
            steps {
                echo "Building Docker image: ${env.FULL_IMAGE}"
                sh """
                    docker build \\
                        --build-arg BUILD_DATE=\$(date -u +%Y-%m-%dT%H:%M:%SZ) \\
                        --build-arg GIT_SHA=${GIT_SHA} \\
                        --build-arg BRANCH=${env.BRANCH_NAME} \\
                        -t ${env.FULL_IMAGE} \\
                        -t ${env.LATEST_IMAGE} \\
                        .
                """
            }
        }

        // --------------------------------------------------
        stage('Docker Push') {
            steps {
                echo "Pushing to Docker Hub: ${env.FULL_IMAGE}"
                sh """
                    echo \$DOCKER_PASS | docker login -u \$DOCKER_USER --password-stdin
                    docker push ${env.FULL_IMAGE}
                    docker push ${env.LATEST_IMAGE}
                    docker logout
                """
            }
        }

        // --------------------------------------------------
        stage('Deploy') {
            steps {
                echo "Deploying ${env.FULL_IMAGE} on this server..."
                sh """
                    export DOCKER_IMAGE=${env.FULL_IMAGE}
                    chmod +x deploy.sh
                    ./deploy.sh ${env.FULL_IMAGE}
                """
            }
        }

        // --------------------------------------------------
        stage('Health Check') {
            steps {
                echo "Verifying application health..."
                sh """
                    sleep 10
                    curl -sf http://localhost:${APP_PORT}/health || \
                      (echo 'Health check failed!' && docker logs ${CONTAINER_NAME} --tail=50 && exit 1)
                    echo 'Application is running successfully!'
                """
            }
        }

        // --------------------------------------------------
        stage('Cleanup') {
            steps {
                sh 'docker image prune -f --filter "until=24h" 2>/dev/null || true'
                echo 'Cleanup done.'
            }
        }
    }

    post {
        success {
            echo """
            ✅ Pipeline SUCCESS
            Branch : ${env.BRANCH_NAME}
            Image  : ${env.FULL_IMAGE}
            Env    : ${env.ENV_NAME}
            """
        }
        failure {
            echo """
            ❌ Pipeline FAILED
            Branch : ${env.BRANCH_NAME}
            Stage  : ${env.STAGE_NAME}
            """
        }
        always {
            sh 'docker logout 2>/dev/null || true'
        }
    }
}
