pipeline {

    agent any
 
    environment {
        AWS_ACCESS_KEY_ID = credentials('AWS_ACCESS_KEY_ID')
        AWS_SECRET_ACCESS_KEY = credentials('AWS_SECRET_ACCESS_KEY')
        AWS_DEFAULT_REGION     = 'us-east-1'                   // Set your AWS region

        gitRepo = 'https://github.com/marcuskohtongjie95/iac-vprofile.git'
        branchName = 'stage'
        githubCredentials = credentials('GITHUB_TOKEN') // Use Jenkins Credentials to store the GitHub PAT
        S3_BUCKET             = 'marcuskoh95-gitops-proj-s3-terraformstate' // Your existing S3 bucket for storing state
        DYNAMODB_TABLE        = 'gitops-proj-dynamodb-statelock' // Your existing DynamoDB table for state locking


    }

    triggers {
        // Triggers the build when changes are pushed to GitHub
        githubPush()
    }

    stages{

        stage('Git Checkout'){
            steps {
                git branch: "${branchName}", url: "${gitRepo}"
            }
        }

        stage('Initialize Terraform') {
            steps {
                // Initialize Terraform with backend config for S3 state and DynamoDB for locking
                sh '''
                terraform init \
                -backend-config="bucket=$S3_BUCKET" \
                -backend-config="terraform.tfstate" \
                -backend-config="region=$AWS_DEFAULT_REGION" \
                -backend-config="dynamodb_table=$DYNAMODB_TABLE" \
                -backend-config="encrypt=true"
                '''
            }
        }

        stage('Terraform Plan') {
            steps {
                // Run Terraform plan to show infrastructure changes
                sh '''
                terraform plan -var="aws_region=$AWS_DEFAULT_REGION"
                '''
            }
        }

    }
}