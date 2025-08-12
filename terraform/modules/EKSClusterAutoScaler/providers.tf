
terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      #version = "~> 2.11"
    }

    helm = {
      source = "hashicorp/helm"
    }
  }
}