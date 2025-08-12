terraform {
  
  required_providers {
    aws = {
      source = "hashicorp/aws"
      
    }

    tls = {
      source = "hashicorp/tls"
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
    }
    helm = {
      source = "hashicorp/helm"
    }
  }
}

provider "kubernetes" {
  alias = "k8s"
  host   = module.eks.cluster_endpoint
  cluster_ca_certificate =  base64decode(module.eks.cluster_certificate_authority_data)# base64decode(data.aws_eks_cluster.this.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.this.token
}
