pipeline {
    agent any

    environment {
        AWS_REGION = 'us-east-1'
        EC2_HOST = '43.204.218.158'
        EC2_USER = 'ubuntu'
        SSH_KEY = './terraform_files/jenkins.pem'  // ensure the pem file exists
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
                echo 'Compiling and packaging application'
                sh 'mvn clean package'
            }
        }

        stage('Terraform Setup (EKS Cluster)') {
    steps {
        echo 'Initializing Terraform...'
        sh '''
            terraform init
            terraform validate
            terraform plan
            terraform apply -auto-approve
        '''
    }
}

        stage('Configure Kubeconfig') {
            steps {
                echo 'Updating kubeconfig for EKS cluster'
                sh """
                    aws eks update-kubeconfig --region ${AWS_REGION} --name medicure-cluster --alias medicure-cluster
                    mkdir -p /var/lib/jenkins/.kube
                    cp ~/.kube/config /var/lib/jenkins/.kube/config
                    chown -R jenkins:jenkins /var/lib/jenkins/.kube
                """
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                echo 'Deploying to Kubernetes cluster'
                sh """
                    kubectl apply -f deployment.yml
                    kubectl apply -f service.yml
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
            echo 'Pipeline failed. Check the logs for details.'
        }
    }
}
