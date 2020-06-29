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

    stage('Build App') {
      steps {
          sh ''
      }
    }

    stage('Peform unit tests') {
      steps {
          sh ''
      }
    }

    stage('Publish App in Registry') {
      steps {
          sh 'cd app; docker build -t digitalemil/thesimplegym:cicddemo-v$BUILD_NUMBER .; cd ..'
          sh 'docker push digitalemil/thesimplegym:cicddemo-v$BUILD_NUMBER'
      }
    }

    stage('Terraform Plan Testcluster') {
      steps {
	    sh './terraform -version'
        sh './terraform init'
        sh './terraform plan -var="name=testcluster$BUILD_NUMBER" -out myplan'
      }      
    }

    stage('Approval for Testcluster') {
      steps {
        script {
          def userInput = input(id: 'confirm', message: 'Apply Terraform?', parameters: [ [$class: 'BooleanParameterDefinition', defaultValue: false, description: 'Apply terraform', name: 'Confirm'] ])
        }
      }
    }

    stage('Terraform Apply Testcluster') {
      steps {
        sh './terraform apply -input=false myplan'
	    sh './create-config.sh' 
        withCredentials([file(credentialsId: 'key.json', variable: 'KEY')]) {
            sh 'gcloud auth activate-service-account terraform@esiemes-default.iam.gserviceaccount.com  --key-file=$KEY'
	        sh './kubectl --kubeconfig config get nodes'
        }
      }
    }

    stage('Install App via Helm/Tiller on Testcluster') {
      steps {
        sh 'curl -o helm.tar https://storage.googleapis.com/esiemes-scripts/helm.tar'
	    sh 'tar xf helm.tar --overwrite' 
        sh './kubectl --kubeconfig config apply -f tiller-sa.yaml'
        sh 'export KUBECONFIG=./config; ./helm init --wait --service-account=tiller; sleep 10'
        sh 'export KUBECONFIG=./config; ./helm install --dry-run --set build=${BUILD_NUMBER} ./thegym'
        sh 'export KUBECONFIG=./config; ./helm install --set build=${BUILD_NUMBER} ./thegym'
      }
    }
 

    stage('Approval for Prod') {
      steps {
        script {
          def userInput = input(id: 'confirm', message: 'Promote App to prod?', parameters: [ [$class: 'BooleanParameterDefinition', defaultValue: false, description: 'Promote app to production cluster', name: 'Confirm'] ])
        }
      }
    }

    stage('Install App via Helm/Tiller on Procluster') {
      steps {
 		withCredentials([file(credentialsId: 'prodkubeconfig', variable: 'PRODCONFIG')]) {
        			sh 'export KUBECONFIG=$PRODCONFIG; ./helm install --set build=${BUILD_NUMBER} ./thegym --namespace thegym'
      }
    }

    stage('Terraform Destroy Testcluster') {
      steps {
        sh './terraform destroy -auto-approve'
      }
    }
  } 
}
