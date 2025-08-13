variable "eks_oidc_issuer_url" {
  type = string
}

variable "eks_cluster_name" {
  type = string
}

variable "eks_cluster_endpoint" {
  type = string
}

variable "cluster_certificate_authority_data" {
  type = string
}
variable "eks_oidc_provider_arn" {
  type = string
}
variable "eks_oidc_provider" {
  type = string
}