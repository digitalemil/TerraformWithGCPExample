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
        sh 'curl -o terraform https://storage.googleapis.com/esiemes-scripts/terraform'
	sh 'chmod +x terraform'
	sh './terraform -version'
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
