pipeline {
    agent any

    environment {
        // AWS credentials
        AWS_ACCESS_KEY_ID = credentials('awslogin')
        AWS_SECRET_ACCESS_KEY = credentials('awslogin')
        // EC2 server details
        EC2_USER = 'ubuntu'
        EC2_HOST = '43.204.218.158'  // Use Elastic IP or Public DNS
        SSH_KEY_PATH = '/var/lib/jenkins/.ssh/jenkins.pem'  // Path to your Jenkins EC2 key
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
                echo 'Compiling, testing, and packaging the application'
                sh 'mvn package'
            }
        }

        stage('AWS Login') {
            steps {
                echo 'AWS credentials loaded'
            }
        }

        stage('Setup Kubernetes Cluster') {
            steps {
                dir('terraform_files') {
                    echo 'Initializing Terraform...'
                    sh 'terraform init'
                    echo 'Validating Terraform configuration...'
                    sh 'terraform validate'
                    echo 'Applying Terraform plan...'
                    sh 'terraform apply --auto-approve'
                    sh 'sleep 20'
                }
            }
        }

        stage('Deploy Kubernetes') {
            steps {
                echo 'Deploying Kubernetes manifests to EC2'
                sshagent(['8150cbb1-c684-4cd2-8240-6420058329bc']) {
                    sh """
                        # Ensure the key is readable (no sudo needed)
                        chmod 400 ${SSH_KEY_PATH}

                        # Copy files to EC2
                        scp -o StrictHostKeyChecking=no -i ${SSH_KEY_PATH} deployment.yml ${EC2_USER}@${EC2_HOST}:/home/ubuntu/
                        scp -o StrictHostKeyChecking=no -i ${SSH_KEY_PATH} service.yml ${EC2_USER}@${EC2_HOST}:/home/ubuntu/

                        # Apply Kubernetes manifests
                        ssh -o StrictHostKeyChecking=no -i ${SSH_KEY_PATH} ${EC2_USER}@${EC2_HOST} "kubectl apply -f /home/ubuntu/"
                    """
                }
            }
        }
    }
}
