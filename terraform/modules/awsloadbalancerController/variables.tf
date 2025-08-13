variable "eks_oidc_issuer_url" {
  type = string
    validation {
    condition = length(var.eks_oidc_issuer_url) > 0
    error_message = "EKS Cluster OIDC issuer URL must be provided"
  }
}

variable "eks_cluster_name" {
  type = string
    validation {
    condition = length(var.eks_cluster_name) > 0
    error_message = "EKS Cluster name must be provided"
  }
}

variable "eks_cluster_endpoint" {
  type = string
  validation {
    condition = length(var.eks_cluster_endpoint) > 0
    error_message = "EKS Cluster endpoint must be provided"
  }
}

variable "cluster_certificate_authority_data" {
  type = string
    validation {
    condition = length(var.cluster_certificate_authority_data) > 0
    error_message = "EKS Cluster authority data must be provided"
  }
}
variable "eks_oidc_provider_arn" {
  type = string
    validation {
    condition = length(var.eks_oidc_provider_arn) > 0
    error_message = "EKS Cluster oidc provider arn must be provided"
  }
}

variable "vpc_id" {
  type = string
}

variable "eks_oidc_provider" {
  type = string
}
variable "eks_cluster_arn" {
  type = string
}