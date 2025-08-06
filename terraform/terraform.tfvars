eks_environments = {
  dev = {
    # Global variables
    cluster_name                   = "storio-dev-eks-cluster"
    #env                            = "default"
    region                         = local.env.aws_region
    vpc_id                         = aws_vpc.this.id #"vpc-02af529e05c41b6bb"
    vpc_cidr                       = local.workspace.cidr_block
    public_subnet_ids              = [for subnet in aws_subnet.app : subnet.id] #["subnet-09aeb297a112767b2", "subnet-0e25e76fb4326ce99"]
    cluster_version                = "1.33"
    cluster_endpoint_public_access = true
    #ecr_names                      = ["codedevops"]

    # EKS variables
    eks_managed_node_groups = {
      eks-dev-ng = {
        min_size       = 1
        max_size       = 1
        desired_size   = 1
        instance_types = ["t3.small"]
        capacity_type  = "ON_DEMAND"
        disk_size      = 60
        ebs_optimized  = true
        iam_role_additional_policies = {
          ssm_access        = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
          cloudwatch_access = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
          service_role_ssm  = "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM"
          default_policy    = "arn:aws:iam::aws:policy/AmazonSSMManagedEC2InstanceDefaultPolicy"
          custom = aws_iam_policy.node_efs_policy.arn
        }
      }
    }

    cluster_security_group_additional_rules = {

      
        allow_all_egress = [
          {
            type = "egress"
            description = "allow all outbound"
            from_port = 0
            to_port = 0
            protocol = "-1"
            cidr_block = ["0.0.0.0/0"]
          }
        ]
      
    }

    # EKS Cluster Logging
    enabled_log_types = [
      "audit"
      ]
    eks_access_entries = {
      viewer = {
        user_arn = []
      }
      admin = {
        user_arn = [
          "arn:aws:iam::"+ data.aws_caller_identity.current.account_id + ":root",
          "arn:aws:iam::"+ data.aws_caller_identity.current.account_id + ":group/admin"]
      }
    }
    # EKS Addons variables 
    coredns_config = {
      replicaCount = 1
    }
  }

}