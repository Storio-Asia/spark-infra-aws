variable "region" {
  type        = any
  default     = "ap-southeast-5"
  description = "value of the region where the resources will be created"
}

variable "eks_environments" {
  type = any

  description = "EKS environment configuration"
}

