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
                    #!/bin/bash
                    # Step 1: Add ArgoCD Helm repository
                    helm repo add argo https://argoproj.github.io/argo-helm

                    # Step 2: Update the Helm repositories
                    helm repo update

                    # Step 3: Check if ServiceAccount already exists
                    if kubectl get serviceaccount argocd-application-controller --namespace argocd > /dev/null 2>&1; then
                        echo "ServiceAccount argocd-application-controller already exists, skipping Helm install."
                    else
                        # Step 4: Install ArgoCD using Helm
                        helm upgrade --install argocd argo/argo-cd --namespace argocd --create-namespace

                        # Step 5: Wait for ArgoCD to be ready
                        kubectl wait --namespace argocd \
                          --for=condition=available deployment/argocd-server \
                          --timeout=600s

                        # Step 6: Expose ArgoCD server service as LoadBalancer
                        kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "LoadBalancer"}}'
                    fi

                    # Step 7: Wait for the LoadBalancer external IP/hostname to be assigned
                    echo "Waiting for ArgoCD server LoadBalancer IP..."
                    timeout=600 # Timeout set to 10 minutes
                    end=$((SECONDS + timeout))
                    while [ $SECONDS -lt $end ]; do
                        IP=$(kubectl get svc argocd-server -n argocd -o jsonpath='{.status.loadBalancer.ingress[0].hostname}' || true)
                        if [[ -n "$IP" ]]; then
                            echo "ArgoCD is available at: http://$IP"
                            break
                        else
                            echo "Waiting for LoadBalancer IP..."
                            sleep 30
                        fi
                    done

                    if [[ -z "$IP" ]]; then
                        echo "Failed to get LoadBalancer IP after $timeout seconds."
                        exit 1
                    fi
                    '''
                }
            }
        }


        stage('Deploy Monitoring Stack (Prometheus and Grafana)') {
            steps {
                script {
                    sh '''
                    #!/bin/bash

                    # Step 1: Add Prometheus and Grafana Helm repositories
                    helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
                    helm repo add grafana https://grafana.github.io/helm-charts

                    # Step 2: Update Helm repositories
                    helm repo update

                    # Step 3: Check if Prometheus is already installed
                    if helm list -n monitoring | grep prometheus > /dev/null 2>&1; then
                        echo "Prometheus is already deployed, skipping installation."
                    else
                        # Step 4: Install Prometheus using Helm
                        echo "Deploying Prometheus..."
                        helm upgrade --install prometheus prometheus-community/prometheus --namespace monitoring --create-namespace
                    fi

                    # Step 5: Wait for Prometheus to be ready
                    kubectl wait --namespace monitoring \
                    --for=condition=available deployment/prometheus-server \
                    --timeout=600s

                    # Step 6: Check if Grafana is already installed
                    if helm list -n monitoring | grep grafana > /dev/null 2>&1; then
                        echo "Grafana is already deployed, skipping installation."
                    else
                        # Step 7: Install Grafana using Helm
                        echo "Deploying Grafana..."
                        helm upgrade --install grafana grafana/grafana --namespace monitoring --create-namespace \
                        --set adminPassword='admin' \
                        --set service.type=LoadBalancer
                    fi

                    # Step 8: Wait for Grafana to be ready
                    kubectl wait --namespace monitoring \
                    --for=condition=available deployment/grafana \
                    --timeout=600s

                    # Step 9: Get Grafana LoadBalancer URL
                    echo "Waiting for Grafana LoadBalancer IP..."
                    timeout=600
                    end=$((SECONDS + timeout))
                    while [ $SECONDS -lt $end ]; do
                        GRAFANA_IP=$(kubectl get svc grafana -n monitoring -o jsonpath='{.status.loadBalancer.ingress[0].hostname}' || true)
                        if [[ -n "$GRAFANA_IP" ]]; then
                            echo "Grafana is available at: http://$GRAFANA_IP"
                            break
                        else
                            echo "Waiting for Grafana LoadBalancer IP..."
                            sleep 30
                        fi
                    done

                    if [[ -z "$GRAFANA_IP" ]]; then
                        echo "Failed to get Grafana LoadBalancer IP after $timeout seconds."
                        exit 1
                    fi
                    '''
                }
            }
        }

    }
}