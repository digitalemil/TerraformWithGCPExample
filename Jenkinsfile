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
	sh 'rm -fr terraform-google-kubernetes-engine'
        sh 'git clone https://github.com/terraform-google-modules/terraform-google-kubernetes-engine.git'
      }
    }

    stage('Terraform Plan') {
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

    stage('Terraform Apply') {
      steps {
          sh './terraform apply -input=false myplan'
	  sh './create-config.sh' 
withCredentials([file(credentialsId: 'key.json', variable: 'KEY')]) {
    // some block
          sh 'gcloud auth activate-service-account terraform@esiemes-default.iam.gserviceaccount.com  --key-file=$KEY'
	  sh 'export PATH=$PATH:/snap/google-cloud-sdk/138/bin; ./kubectl --kubeconfig config get nodes'
}
      }
    }

stage('Build, test & publish App') {
      steps {
          sh 'cd app; sudo docker build -t digitalemil/thesimplegym:cicddemo-v$BUILD_NUMBER; cd ..'
	      sh 'sudo docker push digitalemil/thesimplegym:cicddemo-v$BUILD_NUMBER' 
      }
    }
  }

stage('Install App via Helm/Tiller') {
      steps {
          sh 'curl -o helm.tar https://storage.googleapis.com/esiemes-scripts/helm.tar'
	      sh 'tar xf helm.tar' 
          sh './kubectl apply -f tiller-sa.yaml'
          sh './helm init --service-account=tiller'
          sh './helm install --set build=${BUILD_NUMBER} --dry-run --debug ./thegym'
      }
    }
  } 

}
