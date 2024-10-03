pipeline {

    agent any
 
    environment {
        AWS_ACCESS_KEY_ID = credentials('AWS_ACCESS_KEY_ID')
        AWS_SECRET_ACCESS_KEY = credentials('AWS_SECRET_ACCESS_KEY')

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
    }
}  
