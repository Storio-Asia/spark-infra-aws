

resource "aws_iam_policy" "EKSAutoScalerPolicy" {
  name        = "AWSEKSAutoScalerPolicy"
  path        = "/"
  description = "AWS EKS Cluster AutoScaler policy"

  policy = data.aws_iam_policy_document.cluster_autoscaler_policy_document.json
  
}

############# AWS EKS Cluster auto scaler role ########################
resource "aws_iam_role" "eks_auto_scaler_role" {
  name = "AmazonEKSAutoScalerControllerRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = var.eks_oidc_provider_arn
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "${replace(var.eks_oidc_issuer_url, "https://", "")}:sub" = "system:serviceaccount:kube-system:cluster-autoscaler"
            "${replace(var.eks_oidc_issuer_url, "https://", "")}:aud" = "sts.amazonaws.com"
          }
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "aeks_autoscaler_attach" {
  role       = aws_iam_role.eks_auto_scaler_role.name
  policy_arn = aws_iam_policy.EKSAutoScalerPolicy.arn
}

resource "kubernetes_service_account" "eks_autosacler_sa" {
  metadata {
    name      = "cluster-autoscaler"
    namespace = "kube-system"
    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.eks_auto_scaler_role.arn
    }
  }
}


resource "helm_release" "cluster_autoscaler" {
  name       = "clusterautoscaler"
  namespace  = "kube-system"
  repository = "https://kubernetes.github.io/autoscaler"
  chart      = "cluster-autoscaler"
  version    = "9.49.0"
 
  set = [
    {
      name  = "autoDiscovery.clusterName"
      value = var.eks_cluster_name
    },
    {
      name  = "rbac.serviceAccount.create"
      value = "false"
    },
    {
      name  = "rbac.serviceAccount.name"
      value = kubernetes_service_account.eks_autosacler_sa.metadata[0].name
    }
  ]
}


