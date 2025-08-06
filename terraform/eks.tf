module "eks" {
  source = "terraform-aws-modules/eks/aws"
  version = "21.0.7"
  name = local.workspace.eks.cluster_name
  kubernetes_version = local.workspace.eks.cluster_version
  enabled_log_types = local.workspace.eks.cluster_enabled_log_types
  cloudwatch_log_group_retention_in_days = 30
  endpoint_public_access = true
  create_node_iam_role = true

  addons = {
    coredns = {
      most_recent                 = true
      resolve_conflicts_on_create = "OVERWRITE"
      configuration_values        = jsonencode(local.workspace.eks.coredns_config)
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent              = true
      service_account_role_arn = aws_iam_role.vpc_cni.arn
    }
  }

  vpc_id     = local.workspace.eks.vpc_id
  subnet_ids = local.workspace.eks.public_subnet_ids
 

  eks_managed_node_groups = local.workspace.eks.eks_managed_node_groups

  node_security_group_additional_rules = local.workspace.eks.cluster_security_group_additional_rules

  enable_cluster_creator_admin_permissions = false

  access_entries = {
    for k in local.workspace.eks.eks_access_entries : k.username => {
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
resource "aws_iam_role" "vpc_cni" {
  name               = "${local.workspace.eks.prefix}-vpc-cni"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "${module.eks.oidc_provider_arn}"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "${module.eks.oidc_provider}:sub": "system:serviceaccount:kube-system:aws-node"
        }
      }
    }
  ]
}
EOF
}
resource "aws_iam_role_policy_attachment" "vpc_cni" {
  role       = aws_iam_role.vpc_cni.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"

}


resource "aws_iam_policy" "node_efs_policy" {
  name        = "eks_node_efs-${local.workspace.client}-${local.workspace.env}"
  path        = "/"
  description = "Policy for EFKS nodes to use EFS"

  policy = jsonencode({
    "Statement": [
        {
            "Action": [
                "elasticfilesystem:DescribeMountTargets",
                "elasticfilesystem:DescribeFileSystems",
                "elasticfilesystem:DescribeAccessPoints",
                "elasticfilesystem:CreateAccessPoint",
                "elasticfilesystem:DeleteAccessPoint",
                "ec2:DescribeAvailabilityZones"
            ],
            "Effect": "Allow",
            "Resource": "*",
            "Sid": ""
        }
    ],
    "Version": "2012-10-17"
}
  )
}
