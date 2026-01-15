pipeline {
    agent any

    environment {
        // --- עדכון נתונים ---
        AWS_ACCOUNT_ID = "002757291574" 
        AWS_REGION     = "us-east-1"
        S3_BUCKET      = "my-project-artifacts-sd29pe"
        APP_SERVER_IPS = "98.92.198.53,3.233.238.233" 
        
        // הגדרות קבועות
        IMAGE_REPO     = "my-python-app"
        IMAGE_TAG      = "${env.BUILD_NUMBER}"
        ECR_URL        = "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"
        SSH_CRED_ID    = "app-server-ssh-key" 
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/bendagan85/devops-end-to-end-project4.git'
            }
        }

        stage('Lint & Static Analysis') {
            steps {
                sh 'pip install flake8'
                sh 'python3 -m flake8 app/ --exclude=venv --ignore=W292'
            }
        }

        stage('Unit Tests') {
            steps {
                sh 'pip install -r app/requirements.txt'
                sh 'python3 -m pytest app/test_main.py'
            }
        }

        stage('Build & Push to ECR') {
            steps {
                script {
                    sh "aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${ECR_URL}"
                    sh "docker build -t ${IMAGE_REPO}:${IMAGE_TAG} ./app"
                    sh "docker tag ${IMAGE_REPO}:${IMAGE_TAG} ${ECR_URL}/${IMAGE_REPO}:${IMAGE_TAG}"
                    sh "docker tag ${IMAGE_REPO}:${IMAGE_TAG} ${ECR_URL}/${IMAGE_REPO}:latest"
                    sh "docker push ${ECR_URL}/${IMAGE_REPO}:${IMAGE_TAG}"
                    sh "docker push ${ECR_URL}/${IMAGE_REPO}:latest"
                }
            }
        }

        stage('Upload Artifacts to S3') {
            steps {
                script {
                    sh 'zip -r app-release-${BUILD_NUMBER}.zip ./app'
                    sh "aws s3 cp app-release-${BUILD_NUMBER}.zip s3://${S3_BUCKET}/"
                }
            }
        }

        stage('Deploy to Servers') {
            steps {
                sshagent([SSH_CRED_ID]) {
                    script {
                        // פיצול רשימת השרתים למערך
                        def servers = APP_SERVER_IPS.split(',')
                        
                        // לולאה שרצה על כל שרת ברשימה
                        for (server_ip in servers) {
                            echo "Starting deployment to server: ${server_ip}"
                            
                            sh """
                            ssh -o StrictHostKeyChecking=no ubuntu@${server_ip} '
                                aws ecr get-login-password --region ${AWS_REGION} | sudo docker login --username AWS --password-stdin ${ECR_URL}
                                sudo docker stop my-app || true
                                sudo docker rm my-app || true
                                sudo docker pull ${ECR_URL}/${IMAGE_REPO}:latest
                                sudo docker run -d --name my-app -p 5000:5000 ${ECR_URL}/${IMAGE_REPO}:latest
                            '
                            """
                        }
                    }
                }
            }
        }

        stage('Health Check') {
            steps {
                // נותנים לאפליקציה רגע לעלות
                sh "sleep 10" 
                echo "Deployment finished to all servers. Please check the ALB URL manually."
            }
        }
    }

    post {
        success {
            echo "Deployment Successful!"
        }
        failure {
            echo "Deployment Failed!"
        }
    }
}