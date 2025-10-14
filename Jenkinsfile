pipeline {
    agent any

    stages {
        stage('Git Checkout') {
            steps {
                echo 'This stage is to clone the repo from github'
                git branch: 'master', url: 'https://github.com/chandrukandagallu/star-agile-health-care.git'
            }
        }

        stage('Create Package') {
            steps {
                echo 'This stage will compile, test, package my application'
                sh 'mvn package'
            }
        }

        stage('AWS-Login') {
            steps {
                withCredentials([aws(accessKeyVariable: 'AWS_ACCESS_KEY_ID',
                                     credentialsId: 'awslogin',
                                     secretKeyVariable: 'AWS_SECRET_ACCESS_KEY')]) {
                    echo 'AWS credentials loaded'
                }
            }
        }

        stage('Setting the Kubernetes Cluster') {
            steps {
                dir('terraform_files') {
                    sh 'terraform init'
                    sh 'terraform validate'
                    sh 'terraform apply --auto-approve'
                    sh 'sleep 20'
                }
            }
        }

        stage('Deploy Kubernetes') {
            steps {
                sshagent(['jenkins']) {
                    sh '''
                        chmod 600 ./terraform_files/jenkins.pem
                        scp -o StrictHostKeyChecking=no -i ./terraform_files/jenkins.pem deployment.yml ubuntu@13.201.130.117:/home/ubuntu/
                        scp -o StrictHostKeyChecking=no -i ./terraform_files/jenkins.pem service.yml ubuntu@13.201.130.117:/home/ubuntu/
                        ssh -o StrictHostKeyChecking=no -i ./terraform_files/jenkins.pem ubuntu@13.201.130.117 "kubectl apply -f /home/ubuntu/"
                    '''
                }
            }
        }
    }
}
