output "region" {
  description = "Amazon Web Service EKS Cluster region"
  value       = var.region
}

output "cluster_name" {
  description = "Amazon Web Service EKS Cluster Name"
  value       = module.eks.cluster_name
}

output "cluster_endpoint" {
  description = "Endpoint for Amazon Web Service EKS "
  value       = module.eks.cluster_endpoint
}

output "cluster_security_group_id" {
  description = "Security group ID for the Amazon Web Service EKS Cluster "
  value       = module.eks.cluster_security_group_id
}

output "argocd_loadbalancer_endpoint" {
  description = "The ArgoCD server LoadBalancer endpoint"
  value       = data.kubernetes_service.argocd_server.status[0].load_balancer[0].ingress[0].hostname
}

