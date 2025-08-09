output "cluster_id" {
  value = module.eks.cluster_id
}

output "cluster_name"{
    value = module.eks.cluster_name
}

output "oidc_provider" {
  value = module.eks.oidc_provider
}

output "cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

output "cluster_certificate_authority_data" {
  value = module.eks.cluster_certificate_authority_data
}
output "cluster_tls_certificate_sha1_fingerprint" {
  value = module.eks.cluster_tls_certificate_sha1_fingerprint
}

output "cluster_oidc_issuer_url" {
  value = module.eks.cluster_oidc_issuer_url
}