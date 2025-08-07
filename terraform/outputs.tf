output "vpcid" {
    value = aws_vpc.this.id
}

output "rds"{
    value = aws_db_instance.mysql.endpoint
    description = "DNS address of RDS insance"
}

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

output "efs_filesystem_id" {
  value = module.efs.efs_id
}