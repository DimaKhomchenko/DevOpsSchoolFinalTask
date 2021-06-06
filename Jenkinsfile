pipeline {
    agent any

    stages {
        stage('Terraform Init'){
            steps{
                sh 'terraform -chdir=/tmp/final/terraform/ init'
            }
        }

        stage('Terrafrom plan'){
            steps{
                sh 'terraform -chdir=/tmp/final/terraform/ plan -out=/tmp/final/terraform/main.tfplan'
            }
        }
        
        stage('Terraform apply'){
            steps{
                sh 'terraform -chdir=/tmp/final/terraform/ apply /tmp/final/terraform/main.tfplan'
            }
        }
    } 
}