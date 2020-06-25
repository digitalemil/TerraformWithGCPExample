pipeline {

  agent any

  environment {
    SVC_ACCOUNT_KEY = credentials('serviceaccount')
  }

  stages {

    stage('Checkout') {
      steps {
        checkout scm
        sh 'mkdir -p creds' 
        sh 'echo $SVC_ACCOUNT_KEY | base64 -d > ./creds/serviceaccount.json'
      }
    }

    stage('TF Plan') {
      steps {
        sh 'curl -o terraform.zip https://releases.hashicorp.com/terraform/0.12.27/terraform_0.12.27_linux_amd64.zip'
	sh 'unzip terraform.zip'
unzip zipFile: 'terraform.zip', dir: '.'	
sh 'chmod +x terraform.zip'
	sh './terraform — version'
        sh './terraform init'
        sh './terraform plan -out myplan'
      }      
    }

    stage('Approval') {
      steps {
        script {
          def userInput = input(id: 'confirm', message: 'Apply Terraform?', parameters: [ [$class: 'BooleanParameterDefinition', defaultValue: false, description: 'Apply terraform', name: 'confirm'] ])
        }
      }
    }

    stage('TF Apply') {
      steps {
 
          sh './terraform apply -input=false myplan'
      }
    }

  } 

}
