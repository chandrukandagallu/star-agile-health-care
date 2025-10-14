pipeline {
    agent any

    environment {
        // AWS credentials stored in Jenkins (ID: awslogin)
        AWS_ACCESS_KEY_ID     = credentials('awslogin')
        AWS_SECRET_ACCESS_KEY = credentials('awslogin')
        
        // EC2 server details
        EC2_USER    = 'ubuntu'
        EC2_HOST    = '43.204.218.158'   // Use your public IP
        SSH_KEY_PATH = '/var/lib/jenkins/.ssh/jenkins.pem'
        
        // AWS region (change if needed)
        AWS_REGION = 'us-east-1'
    }

    stages {

        stage('Git Checkout') {
            steps {
                echo 'Cloning repo from GitHub'
                git branch: 'master', url: 'https://github.com/chandrukandagallu/star-agile-health-care.git'
            }
        }

        stage('Build Package') {
            steps {
                echo 'Compiling and packaging the application'
                sh 'mvn clean package'
            }
        }

        stage('Terraform Setup') {
            steps {
                dir('terraform_files') {
                    echo 'Initializing Terraform...'
                    sh 'terraform init'
                    echo 'Validating Terraform configuration...'
                    sh 'terraform validate'
                    echo 'Applying Terraform plan...'
                    sh 'terraform apply -auto-approve'
                }
            }
        }

        stage('Deploy to EC2') {
            steps {
                echo 'Copying artifact to EC2'
                sh """
                    scp -o StrictHostKeyChecking=no -i ${SSH_KEY_PATH} target/*.jar ${EC2_USER}@${EC2_HOST}:/home/ubuntu/
                """
                echo 'Running application on EC2'
                sh """
                    ssh -o StrictHostKeyChecking=no -i ${SSH_KEY_PATH} ${EC2_USER}@${EC2_HOST} \\
                    'nohup java -jar /home/ubuntu/*.jar > app.log 2>&1 &'
                """
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                echo 'Deploying to Kubernetes...'
                sh """
                    # Set kubeconfig for Jenkins
                    export KUBECONFIG=/var/lib/jenkins/.kube/config

                    # Apply Kubernetes deployment
                    kubectl apply -f k8s-deployment.yaml

                    # Wait for rollout to complete
                    kubectl rollout status deployment/medicure-deployment
                """
            }
        }
    }

    post {
        success {
            echo 'Pipeline executed successfully!'
        }
        failure {
            echo 'Pipeline failed. Check logs for details.'
        }
    }
}
