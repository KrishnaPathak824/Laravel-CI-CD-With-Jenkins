pipeline {
    agent {
        docker { image 'composer:latest' }
    }

    environment {
        REGISTRY      = "docker.io/jhinga"  
        APP_NAME      = "demo-app"
        BRANCH_NAME   = "${env.GIT_BRANCH}".replaceAll("/", "-")
        IMAGE_TAG     = "${BRANCH_NAME}-${env.BUILD_NUMBER}"
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/KrishnaPathak824/Laravel-CI-CD-With-Jenkins'
            }
        }

        stage('Install PHP Dependencies & Test') {
            steps {
                sh '''
                    cp .env.example .env
                    composer install --no-interaction --prefer-dist
                    php artisan key:generate
                    ./vendor/bin/phpunit --testdox
                '''
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    sh """
                        docker build \
                          --build-arg APP_ENV=production \
                          -t $REGISTRY/$APP_NAME:$IMAGE_TAG \
                          -t $REGISTRY/$APP_NAME:latest .
                    """
                }
            }
        }

        stage('Push Docker Image') {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'dockerhub-creds', 
                    usernameVariable: 'USER', 
                    passwordVariable: 'PASS'
                )]) {
                    sh '''
                        echo $PASS | docker login -u $USER --password-stdin
                        docker push $REGISTRY/$APP_NAME:$IMAGE_TAG
                        docker push $REGISTRY/$APP_NAME:latest
                    '''
                }
            }
        }

        stage('Release Tag') {
            when { branch 'main' }
            steps {
                script {
                    def version = "v1.${env.BUILD_NUMBER}"
                    sh "git tag -a ${version} -m 'Release ${version}'"
                    sh "git push origin ${version}"
                }
            }
        }

        stage('Deploy') {
            steps {
                script {
                    // Example: deploy via SSH to remote server
                    sshagent(['deploy-server-ssh']) {
                        sh """
                            ssh user@your-server '
                                docker pull $REGISTRY/$APP_NAME:latest &&
                                docker compose -f /opt/laravel/docker-compose.yml up -d
                            '
                        """
                    }
                }
            }
        }
    }

    post {
        success {
            echo "✅ Build ${env.BUILD_NUMBER} succeeded and deployed."
        }
        failure {
            echo "❌ Build ${env.BUILD_NUMBER} failed."
        }
    }
}
