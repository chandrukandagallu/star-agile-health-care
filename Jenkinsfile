pipeline {
    agent any

    environment {
        // Set default AWS region
        AWS_REGION = 'ap-south-1'
        // Terraform directory
        TERRAFORM_DIR = 'terraform_files'
    }

    stages {

        // 1️⃣ Git Checkout
        stage('Git Checkout') {
            steps {
                echo 'Cloning the GitHub repository...'
                git branch: 'master', url: 'https://github.com/chandrukandagallu/star-agile-health-care.git'
            }
        }

        // 2️⃣ Create Package (Maven)
        stage('Create Package') {
            steps {
                echo 'Compiling, testing, and packaging the application...'
                sh 'mvn clean package'
            }
        }

        // 3️⃣ Docker Stages (Optional)
        stage('Docker Build & Push') {
            when {
                expression { true } // Set to true if you want Docker build/push
            }
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

        // 4️⃣ AWS Login / Configure AWS CLI
        stage('AWS Configure') {
            steps {
                withCredentials([
                    string(credentialsId: 'aws_access_key_id', variable: 'AWS_ACCESS_KEY_ID'),
                    string(credentialsId: 'aws_secret_access_key', variable: 'AWS_SECRET_ACCESS_KEY')
                ]) {
                    sh """
                        echo "Configuring AWS CLI..."
                        aws configure set aws_access_key_id $AWS_ACCESS_KEY_ID
                        aws configure set aws_secret_access_key $AWS_SECRET_ACCESS_KEY
                        aws configure set default.region $AWS_REGION
                    """
                }
            }
        }

        // 5️⃣ Terraform Apply (Kubernetes Cluster)
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

        // 6️⃣ Deploy to Kubernetes via SSH
        stage('Deploy to Kubernetes') {
    steps {
        sh """
            kubectl apply -f /var/lib/jenkins/workspace/healthcare/deployment.yml
            kubectl get pods -n default
        """
    }
}

        }
    }

