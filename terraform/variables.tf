variable "region" {
  type        = any
  default     = "ap-southeast-5"
  description = "value of the region where the resources will be created"
}

variable "eks_env" {
  type = any
  description = "EKS env config"
  
}