data "aws_caller_identity" "current" {}

data "tls_certificate" "eks_oidc_issuer_url" {
  url = var.eks_oidc_issuer_url
}

data "aws_eks_cluster" "this" {
  name = var.eks_cluster_name
}

data "aws_eks_cluster_auth" "this" {
  name = var.eks_cluster_name
}