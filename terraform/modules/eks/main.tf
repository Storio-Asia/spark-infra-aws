
module "eks" {
  source = "terraform-aws-modules/eks/aws"
  version = "~>21.0"
  name = var.eks_config.name
  kubernetes_version = var.var.eks_config.kubernetes_version
  enabled_log_types = var.eks_config.enabled_log_types
  cloudwatch_log_group_retention_in_days = var.eks_config.cloudwatch_log_group_retention_in_days
  endpoint_public_access = var.eks_config.endpoint_public_access
  create_node_iam_role = var.eks_config.create_node_iam_role
  vpc_id     = var.eks_config.vpc_id
  subnet_ids = var.eks_config.subnet_ids

  addons = {
    coredns = {
      most_recent                 = true
      resolve_conflicts_on_create = "OVERWRITE"
      configuration_values        = jsonencode(var.eks_config.coredns_config)
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent = true
      before_compute = true
      service_account_role_arn = var.eks_config.cni_service_account_role_arn
    }
  }

  
 

  eks_managed_node_groups = var.eks_config.eks_managed_node_groups
  node_security_group_additional_rules = var.eks_config.node_security_group_additional_rules

  enable_cluster_creator_admin_permissions = var.eks_config. enable_cluster_creator_admin_permissions
  
  access_entries = {
    for k in var.eks_config.access_entries : k.username => {
      kubernetes_groups = []
      principal_arn     = k.username
      policy_associations = {
        single = {
          policy_arn = k.access_policy
          access_scope = {
            type = "cluster"
          }
        }
      }
    }
  }
  tags = local.env.tags
}
#Role for vpc cni




