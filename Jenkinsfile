// This Jenkinsfile is not used currently

pipeline {
    agent any
    environment {
        AWS_ACCESS_KEY_ID = credentials('aws-access-key-id')
        AWS_SECRET_ACCESS_KEY = credentials('aws-secret-access-key')
        AWS_DEFAULT_REGION = 'us-east-1'
    }
    stages {
        stage('Clone repository') {
            steps {
                checkout scm
            }
        }
        stage('Build container') {
            steps {
                sh 'docker-compose build'
            }
        }
        stage('Run containers') {
            steps {
                sh 'docker-compose up -d'
                sleep 10
                sh 'docker-compose restart'

                sh 'docker-compose exec -T backend python manage.py migrate'
                sh 'docker-compose exec -T backend python manage.py loaddata data.json'
            }
        }
        stage('Run tests') {
            parallel {
                stage('backend unit test') {
                    steps {
                        sh 'docker-compose exec -T backend python manage.py test'
                    }
                }
                stage('frontend unit tests') {
                    steps {
                        dir('frontend') {
                            sh 'yarn'
                            sh 'yarn test --watchAll=false --coverage --silent'
                        }
                    }
                }
            }
        }
        stage('Deploy') {
            steps {
                sh 'export AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID}'
                sh 'export AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY}'
                sh 'export AWS_DEFAULT_REGION=${AWS_DEFAULT_REGION}'
                dir('backend') {
                    sh 'eb deploy'
                }
                dir('frontend') {
                    sh 'aws ecr get-login-password --region ${AWS_DEFAULT_REGION} | docker login --username AWS --password-stdin ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com'
                    sh 'docker tag your-image:latest ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com/your-repo:latest'
                    sh 'docker push ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com/your-repo:latest'
                    sh 'aws ecs update-service --cluster your-cluster --service your-service --force-new-deployment'
                }
            }
        }
    }
    post {
        always {
            sh "docker-compose down || true"
            sh "docker system prune -a --volumes -f"
        }
    }
}