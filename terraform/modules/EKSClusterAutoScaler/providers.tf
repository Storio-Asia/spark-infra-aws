provider "kubernetes" {
  host                   = var.eks_cluster_endpoint
  cluster_ca_certificate =  base64decode(var.cluster_certificate_authority_data)# base64decode(data.aws_eks_cluster.this.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.this.token
}

provider "helm" {
  kubernetes {
    host                   = var.eks_cluster_endpoint
    cluster_ca_certificate = base64decode(var.cluster_certificate_authority_data)
    token = data.aws_eks_cluster_auth.this.token
  }
}