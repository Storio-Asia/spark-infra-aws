output "cluster_name" {
  value       = cluster_name
  description = "The name of the created EKS cluster."
}

output "cluster_version" {
  value       = cluster_version
  description = "The version of Kubernetes running on the EKS cluster."
}

output "cluster_endpoint" {
  value       = cluster_endpoint
  description = "The endpoint for the EKS Kubernetes API server."
}

output "access_entries" {
  value = access_entries
}

output "oidc_provider" {
  value = oidc_provider
}

output "oidc_provider_arn" {
  value = oidc_provider_arn

}