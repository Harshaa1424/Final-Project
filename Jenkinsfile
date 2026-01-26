pipeline {
    agent any

    environment {
        DOCKERHUB_USERNAME = 'harshaa1424'
        DEV_REPO  = 'myapp-dev'
        PROD_REPO = 'myapp-prod'
        IMAGE_TAG = "${BUILD_NUMBER}"
        EC2_HOST  = '13.233.144.91'
        EC2_USER  = 'ubuntu'

      
        DOCKERHUB_CRED = dckr_pat_8bALhmXmr0-I36Vz06oFRpatWmI
        GITHUB_TOKEN   = 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
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    if (env.BRANCH_NAME == 'dev') {
                        sh "docker build -t $DOCKERHUB_USERNAME/$DEV_REPO:$IMAGE_TAG ."
                    } else if (env.BRANCH_NAME == 'main') {
                        sh "docker build -t $DOCKERHUB_USERNAME/$PROD_REPO:$IMAGE_TAG ."
                    }
                }
            }
        }

        stage('Docker Login') {
            steps {
                sh """
                echo "$DOCKERHUB_CRED" | docker login -u "$DOCKERHUB_USERNAME" --password-stdin
                """
            }
        }

        stage('Push to DockerHub') {
            steps {
                script {
                    if (env.BRANCH_NAME == 'dev') {
                        sh "docker push $DOCKERHUB_USERNAME/$DEV_REPO:$IMAGE_TAG"
                    } else if (env.BRANCH_NAME == 'main') {
                        sh "docker push $DOCKERHUB_USERNAME/$PROD_REPO:$IMAGE_TAG"
                    }
                }
            }
        }

        stage('Deploy to EC2 (Master Only)') {
            when {
                branch 'main'
            }
            steps {
                sh """
                ssh -o StrictHostKeyChecking=no ubuntu@${EC2_HOST} '
                  docker pull $DOCKERHUB_USERNAME/$PROD_REPO:$IMAGE_TAG &&
                  docker stop myapp || true &&
                  docker rm myapp || true &&
                  docker run -d -p 80:80 --name myapp $DOCKERHUB_USERNAME/$PROD_REPO:$IMAGE_TAG
                '
                """
            }
        }
    }
}
