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

        stage('Update kubeconfig') {
            steps {
                    sh '''
                    aws eks --region us-east-1 update-kubeconfig --name gitops-proj-eks
                    '''
                    }
                }  

        stage('Initialize Terraform') {
            steps {
                dir('terraform') {
                // Initialize Terraform with backend config for S3 state and DynamoDB for locking
                sh '''
                terraform init \
                -backend-config="bucket=$S3_BUCKET" \
                -backend-config="key=terraform.tfstate" \
                -backend-config="region=$AWS_DEFAULT_REGION" \
                -backend-config="dynamodb_table=$DYNAMODB_TABLE" \
                -backend-config="encrypt=true"
                '''
                }
            }
        }

        stage('Terraform Validate') {
            steps {
                dir('terraform') {
                    sh '''
                    terraform validate
                    '''
                }
            }
        }

        stage('Terraform Plan') {
            steps {
                dir('terraform') {
                // Run Terraform plan to show infrastructure changes
                sh '''
                terraform plan
                '''
                }
            }
        }

        stage('Terraform Apply') {
            steps {
                    dir('terraform') {
                    // Run Terraform plan to show infrastructure changes
                    sh '''
                    terraform apply -auto-approve
                    '''
                    }
                }    
            }

        stage('Deploy ArgoCD to EKS') {
            steps {
                script {
                    // Apply ArgoCD Helm chart
                    sh '''
                    # Step 1: Add ArgoCD Helm repository
                    helm repo add argo https://argoproj.github.io/argo-helm

                    # Step 2: Update the Helm repositories
                    helm repo update

                    # Step 3: Install ArgoCD using Helm
                    helm install argocd argo/argo-cd --namespace argocd --create-namespace

                    # Step 4: Wait for ArgoCD to be ready
                    kubectl wait --namespace argocd \
                      --for=condition=available deployment/argocd-server \
                      --timeout=600s
                    '''
                }
            }
        }

    }
}