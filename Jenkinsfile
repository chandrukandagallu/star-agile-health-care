pipeline {
    agent any

    environment {
        AWS_REGION = 'ap-south-1'
        TERRAFORM_DIR = 'terraform_files'
    }

    stages {

        stage('Git Checkout') {
            steps {
                echo 'Cloning the GitHub repository...'
                git branch: 'master', url: 'https://github.com/chandrukandagallu/star-agile-health-care.git'
            }
        }

        stage('Create Package') {
            steps {
                echo 'Compiling, testing, and packaging the application...'
                sh 'mvn clean package'
            }
        }

        stage('Docker Build & Push') {
            when { expression { true } }
            steps {
                echo 'Building Docker image...'
                sh 'docker build -t chandruka/healthcare:1.0 .'

                withCredentials([usernamePassword(credentialsId: 'dockercreds', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                    echo 'Logging into DockerHub...'
                    sh 'echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin'
                }

                echo 'Pushing Docker image...'
                sh 'docker push chandruka/healthcare:1.0'
            }
        }

        stage('AWS Configure') {
            steps {
                withCredentials([
                    string(credentialsId: 'aws_access_key_id', variable: 'AWS_ACCESS_KEY_ID'),
                    string(credentialsId: 'aws_secret_access_key', variable: 'AWS_SECRET_ACCESS_KEY')
                ]) {
                    sh """
                        aws configure set aws_access_key_id $AWS_ACCESS_KEY_ID
                        aws configure set aws_secret_access_key $AWS_SECRET_ACCESS_KEY
                        aws configure set default.region $AWS_REGION
                    """
                }
            }
        }

        stage('Terraform Apply') {
            steps {
                dir("${TERRAFORM_DIR}") {
                    sh 'terraform init -upgrade'
                    sh 'terraform validate'
                    sh 'terraform apply -auto-approve'
                    sh 'sleep 20'
                }
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                sh '''
                    # Delete old Minikube cluster (if exists) to avoid resource issues
                    minikube delete || true

                    # Start Minikube with safe memory/CPU
                    minikube start --driver=docker --memory=1800mb --cpus=2

                    # Use Minikube's docker environment
                    eval $(minikube -p minikube docker-env)

                    # Apply Kubernetes manifests
                    minikube kubectl -- apply -f k8s/deployment.yml
                    minikube kubectl -- apply -f k8s/service.yml

                    # Check pod status
                    minikube kubectl -- get pods -n default
                '''
            }
        }
    }
}
