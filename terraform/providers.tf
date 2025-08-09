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