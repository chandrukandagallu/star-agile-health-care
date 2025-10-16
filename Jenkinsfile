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
        bat 'mvn package'
                          }
            }
    
    /* stage('Create Docker Image') {
      steps {
        echo 'This stage will Create a Docker image'
        bat 'docker build -t chandruka/healthcare:1.0 .'
                          }
            }
     stage('Docker-Login') {
           steps {
              withCredentials([usernamePassword(credentialsId: 'dockercreds', passwordVariable: 'dockerpassword', usernameVariable: 'dockerlogin')]) {
               bat 'docker login -u ${dockerlogin} -p ${dockerpassword}'
                             
                        }
                }
}
    stage('Docker Push-Image') {
      steps {
        echo 'This stage will push my new image to the dockerhub'
        bat 'docker push chandruka/healthcare:1.0'
            }
      } */
    stage('AWS-Login') {
      steps {
        withCredentials([aws(accessKeyVariable: 'AWS_ACCESS_KEY_ID', credentialsId: 'awslogin', secretKeyVariable: 'AWS_SECRET_ACCESS_KEY')]) {
         }
      }
    }
    stage('setting the Kubernetes Cluster') {
      steps {
        dir('terraform_files'){
          bat 'terraform init'
          bat 'terraform validate'
          bat 'terraform apply --auto-approve'
          bat 'sleep 20'
        }
      }
    }
    /*stage('deploy to minikube') {
steps{
  bat 'sudo chmod 600 ./terraform_files/jenkins.pem' 
  bat 'ssh -o StrictHostKeyChecking=no -i ./terraform_files */
    }
 }
   
