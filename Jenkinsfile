pipeline {
    agent any

    environment {
        // --- עדכון נתונים מתוך ה-Terraform Output ---
        AWS_ACCOUNT_ID = "002757291574" 
        AWS_REGION     = "us-east-1"
        APP_SERVER_IP  = "98.92.198.53"
        S3_BUCKET      = "my-project-artifacts-sd29pe"
        
        // הגדרות קבועות
        IMAGE_REPO     = "my-python-app"
        IMAGE_TAG      = "${env.BUILD_NUMBER}"
        ECR_URL        = "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"
        SSH_CRED_ID    = "app-server-ssh-key" 
    }

    stages {
        stage('Checkout') {
            steps {
                // וודא שכתובת הגיט כאן נכונה לריפו שלך
                git branch: 'main', url: 'https://github.com/bendagan85/devops-end-to-end-project4.git'
            }
        }

        stage('Lint & Static Analysis') {
            steps {
                // תיקון: שימוש ב-python3 -m כדי להריץ כלים שלא נמצאים ב-PATH
                sh 'pip install flake8'
                sh 'python3 -m flake8 app/ --exclude=venv'
            }
        }

        stage('Unit Tests') {
            steps {
                sh 'pip install -r app/requirements.txt'
                // תיקון: גם כאן נריץ את pytest דרך פייתון
                sh 'python3 -m pytest app/test_main.py'
            }
        }

        stage('Build & Push to ECR') {
            steps {
                script {
                    // התחברות ל-ECR
                    sh "aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${ECR_URL}"
                    
                    // בניית ה-Image
                    sh "docker build -t ${IMAGE_REPO}:${IMAGE_TAG} ./app"
                    
                    // תיוג ודחיפה
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
                    // התקנת zip למקרה שאין
                    sh 'sudo apt-get install zip -y || true'
                    
                    // דחיסת הקוד
                    sh 'zip -r app-release-${BUILD_NUMBER}.zip ./app'
                    
                    // העלאה לבאקט
                    sh "aws s3 cp app-release-${BUILD_NUMBER}.zip s3://${S3_BUCKET}/"
                }
            }
        }

        stage('Deploy to EC2') {
            steps {
                sshagent([SSH_CRED_ID]) {
                    sh """
                    ssh -o StrictHostKeyChecking=no ubuntu@${APP_SERVER_IP} << 'EOF'
                        # התחברות ל-ECR בתוך שרת האפליקציה
                        aws ecr get-login-password --region ${AWS_REGION} | sudo docker login --username AWS --password-stdin ${ECR_URL}
                        
                        # עצירת קונטיינר ישן 
                        sudo docker stop my-app || true
                        sudo docker rm my-app || true
                        
                        # משיכה והרצה
                        sudo docker pull ${ECR_URL}/${IMAGE_REPO}:latest
                        sudo docker run -d --name my-app -p 5000:5000 ${ECR_URL}/${IMAGE_REPO}:latest
                    EOF
                    """
                }
            }
        }

        stage('Health Check') {
            steps {
                sh "sleep 10" 
                sh "curl -f http://${APP_SERVER_IP}:5000/ || exit 1"
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