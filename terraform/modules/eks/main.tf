
module "eks" {
  source = "terraform-aws-modules/eks/aws"
  version = "~>21.0"
  name = eks_env.name
  kubernetes_version = eks_env.kubernetes_version
  enabled_log_types = eks_env.enabled_log_types
  cloudwatch_log_group_retention_in_days = eks_env.cloudwatch_log_group_retention_in_days
  endpoint_public_access = eks_env.endpoint_public_access
  create_node_iam_role = eks_env.create_node_iam_role
  vpc_id     = eks_env.vpc_id
  subnet_ids = eks_env.subnet_ids #local.workspace.eks.public_subnet_ids

  addons = {
    coredns = {
      most_recent                 = true
      resolve_conflicts_on_create = "OVERWRITE"
      configuration_values        = jsonencode(eks_env.coredns_config)
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent = true
      before_compute = true
      service_account_role_arn = eks_env.cni_service_account_role_arn
    }
  }

  
 

  eks_managed_node_groups = eks_env.eks_managed_node_groups
  node_security_group_additional_rules = eks_env.node_security_group_additional_rules

  enable_cluster_creator_admin_permissions = eks_env. enable_cluster_creator_admin_permissions
  
  access_entries = {
    for k in eks_env.access_entries : k.username => {
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




