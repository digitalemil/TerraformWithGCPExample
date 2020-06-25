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

    stage('Prepare') {
      steps {
        sh 'curl -o terraform https://storage.googleapis.com/esiemes-scripts/terraform'
        sh 'chmod +x terraform'
        sh 'curl -LO https://storage.googleapis.com/kubernetes-release/release/`curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt`/bin/linux/amd64/kubectl'
        sh 'chmod +x kubectl'
	sh 'rm -fr terraform-google-kubernetes-engine.git'
        sh 'git clone https://github.com/terraform-google-modules/terraform-google-kubernetes-engine.git'
      }
    }

    stage('TF Plan') {
      steps {
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
	  sh './create_config.sh'
	  sh './kubectl --kubeconfig config get nodes'
      }
    }

  } 

}
