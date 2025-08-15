


module "eks" {
  source = "terraform-aws-modules/eks/aws"
  version = "~>21.0"
  

  name = var.eks_config.name
  kubernetes_version = var.eks_config.kubernetes_version
  endpoint_public_access = var.eks_config.endpoint_public_access
  endpoint_private_access = var.eks_config.endpoint_private_access
  enable_cluster_creator_admin_permissions = var.eks_config.enable_cluster_creator_admin_permissions
  vpc_id = var.eks_config.vpc_id
  subnet_ids = var.eks_config.subnet_ids
  eks_managed_node_groups = local.node_config_with_efs
  enabled_log_types = var.eks_config.enable_log_types
  access_entries = var.eks_config.access_entries
  create_cloudwatch_log_group = var.eks_config.create_cloudwatch_log_group
  tags = var.eks_config.tags
  addons = {
    coredns = {
      replicaCount = 2
    }
    
    eks-pod-identity-agent = {
      before_compute = true
    }
    kube-proxy = {

    }
    vpc-cni = {
      before_compute = true
      #service_account_role_arn = aws_iam_role.vpc_cni.arn
    }
    aws-efs-csi-driver = {

      service_account_role_arn = aws_iam_role.efs_csi_role.arn
    }

  }
}
#Role for vpc cni
resource "aws_iam_policy" "efs_access" {
  name        = "EKS-EFS-Access"
  description = "Allow EKS worker nodes to mount EFS file systems"
  policy      = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = [
          "elasticfilesystem:DescribeFileSystems",
          "elasticfilesystem:DescribeMountTargets",
          "elasticfilesystem:DescribeAccessPoints",
          "elasticfilesystem:ClientMount",
          "elasticfilesystem:ClientWrite",
          "elasticfilesystem:ClientRootAccess"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role" "vpc_cni" {
  name               = "eks-vpc-cni-role"
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
          "${module.eks.oidc_provider}:aud": "sts.amazonaws.com",
          "${module.eks.oidc_provider}:sub": "system:serviceaccount:kube-system:aws-node"
        }
      }
    },
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "pods.eks.amazonaws.com"
      },
      "Action": [
        "sts:AssumeRole",
        "sts:TagSession"
        ],
      "Condition": {
        "StringEquals" : {
            "aws:SourceArn" : "${module.eks.cluster_arn}"
        },
        "StringLike" : {
          "aws:SourceIdentity" : "system:serviceaccount:kube-system:aws-node"
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

resource "aws_iam_role" "efs_csi_role" {
  name               = "eks_efs_role"
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
        "${module.eks.oidc_provider}:aud": "sts.amazonaws.com",
        "${module.eks.oidc_provider}:sub": "system:serviceaccount:kube-system:efs-csi-controller-sa"
        }
      }
    }
  ]
}
EOF
}
resource "aws_iam_role_policy_attachment" "efs_csi_policy_attachment" {
  role       = aws_iam_role.efs_csi_role.name
  policy_arn = aws_iam_policy.efs_access.arn

}

locals{
 node_config_with_efs = {
    for k, v in var.eks_config.eks_managed_node_groups :
    k => merge(
      v,
      {
        iam_role_additional_policies = merge(
          v.iam_role_additional_policies,
          { efs_access = aws_iam_policy.efs_access.arn }
        )
      }
    )
  }
}

