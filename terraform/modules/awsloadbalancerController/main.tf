



############### Policy for AWS load balancer controller####################

resource "aws_iam_policy" "AWSLoadBalancerControllerIAMPolicy" {
  name        = "AWSLoadBalancerControllerIAMPolicyV2"
  path        = "/"
  description = "AWS EKS Load balancer controller policy"

  policy = file("${path.module}/policies/AWSLoadBalancerControllerIAMPolicy.json")
  
}

############# AWS Load balancer controller role ########################
resource "aws_iam_role" "alb_controller" {
  name = "AmazonEKSLoadBalancerControllerRoleV2"

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
            "${var.eks_oidc_provider}:sub" = "system:serviceaccount:kube-system:aws-load-balancer-controller"
            "${var.eks_oidc_provider}:aud" = "sts.amazonaws.com"
          }
        }
      },
     {
      Effect = "Allow",
      Principal = {
        Service = "pods.eks.amazonaws.com"
      },
      Action = [
        "sts:AssumeRole",
        "sts:TagSession"
      ],
      Condition = {
        StringEquals = {
            "aws:SourceArn" = "${module.eks.cluster_arn}"
        },
        StringLike = {
          "aws:SourceIdentity" = "system:serviceaccount:kube-system:aws-load-balancer-controller"
        }
      }
    }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "alb_controller_attach" {
  role       = aws_iam_role.alb_controller.name
  policy_arn = aws_iam_policy.AWSLoadBalancerControllerIAMPolicy.arn
}

resource "kubernetes_service_account" "alb_controller" {
  metadata {
    name      = "aws-load-balancer-controller"
    namespace = "kube-system"
    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.alb_controller.arn
    }
  }
  provider = kubernetes
}


resource "helm_release" "aws_load_balancer_controller" {
  name       = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  namespace  = "kube-system"
  version    = "1.7.0" # Use the appropriate version

  set = [
    {
      name  = "serviceAccount.create"
      value = "false"
    },
    {
      name  = "serviceAccount.name"
      value = kubernetes_service_account.alb_controller.metadata[0].name
    },
       {
      name  = "vpcId"
      value = var.vpc_id
    },
    {
      name = "clusterName"
      value = var.eks_cluster_name
    }
  ]
  
}