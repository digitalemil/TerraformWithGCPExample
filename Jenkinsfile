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
        script {
          def tfHome = tool name: ‘Terraform’
          env.PATH = "${tfHome}:${env.PATH}"
        }
        sh 'terraform — version'
        sh 'terraform init'
        sh 'terraform plan -out myplan'
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
 
          sh 'terraform apply -input=false myplan'
      }
    }

  } 

}
