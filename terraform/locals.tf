locals {
  env = {
    aws_region = "ap-southeast-5"
    
    tags = {
        Repository = ""
        Environment = "dev"
        Project = "Storio"
        Client = "Storio"
               
    }
    dev = {
      environment = "dev"
      client = "storio"
      aws_region = "ap-southeast-5"
      enable_flow_log = true
      cidr_block = "10.0.0.0/16"
      subnets = {
        web = ["10.0.0.0/20", "10.0.16.0/20","10.0.32.0/20"]
        app = ["10.0.48.0/20","10.0.64.0/20","10.0.80.0/20"]
        db =  ["10.0.96.0/20","10.0.112.0/20","10.0.128.0/20"]
      }
      web_nacl_rules = [
        {
            rule_number = 100
            egress      = false
            protocol    = "tcp"
            rule_action = "allow"
            cidr_block  = "0.0.0.0/0"           # Allow https from Any source inbound for app load balancer. This can be restricted to users ip range if known
            from_port   = "443"
            to_port     = "443"
          },
        {
          
          rule_number = 100
          egress      = true
          protocol    = "-1"
          rule_action = "allow"
          cidr_block  = "0.0.0.0/0"           # Allow All outbound traffic
         
        }

      ]
      app_nacl_rules = [
        {
          rule_number = 100
          egress      = false # ingress
          protocol    = "-1" # allow  all traffic
          rule_action = "allow"
          cidr_block  = "10.0.0.0/16"  # allow all traffic with in the vpc
          from_port   = 0
          to_port     = 0
        },
        {
          rule_number = 100
          egress      = true # egress traffic
          protocol    = "-1" # allow all traffic
          rule_action = "allow"
          cidr_block  = "10.0.0.0/16"  # allow all traffic with in the vpc
          from_port   = 0
          to_port     = 0
        }
      ]
      db_nacl_rules = [
        {
          rule_number = 100
          egress      = false # ingress
          protocol    = "-1" # allow  all traffic
          rule_action = "allow"
          cidr_block  = "0.0.0.0/0"  # allow all traffic with in the vpc
          from_port   = 0
          to_port     = 0
        },
        {
          rule_number = 100
          egress      = true # egress traffic
          protocol    = "-1" # allow all traffic
          rule_action = "allow"
          cidr_block  = "0.0.0.0/0"  # allow all traffic with in the vpc
          from_port   = 0
          to_port     = 0
        },


      ]

      mysql_instance = {
        allocated_storage = 20
        engine = "mysql"
        instance_class = "db.t3.micro"
        username = "admin"
        password = "Storiodev1980" # create ssm secret and add password to it rather than specifying it here.
        publically_accessible = true
        skip_final_snapshot = true
        multi_az = false
      }

      db_instance_sgrules = {
        ingress = [
          {
            description = "allow mysql"
            from_port = 3306
            to_port = 3306
            protocol = "tcp"
            cidr_block = ["0.0.0.0/0"]
          }
        ]
        egress = [
          {
            description = "allow all outbound"
            from_port = 0
            to_port = 0
            protocol = "-1"
            cidr_block = ["0.0.0.0/0"]
          }
        ]
      }
      
      eks = {
        
        k8s_info = lookup(var.eks_environments, local.workspace)
        cluster_name = lookup(local.workspace.eks.k8s_info, "cluster_name")
        region = lookup(local.workspace.eks.k8s_info,"region")
        env = lookup(local.workspace.eks.k8s_info, "env")
        vpc_id = local.workspace.k8s_info.vpc_id
        vpc_cidr   = lookup(local.workspace.eks.k8s_info, "vpc_cidr")
        public_subnet_ids = lookup(local.workspace.eks.k8s_info, "public_subnet_ids") #node groups subnet ids
        cluster_version = lookup(local.workspace.eks.k8s_info, "cluster_version")
        enabled_log_types = lookup(local.workspace.eks.k8s_info, "enabled_log_types")
        eks_managed_node_groups = lookup(local.workspace.eks.k8s_info, "eks_managed_node_groups")
        cluster_security_group_additional_rules = lookup(local.workspace.eks.k8s_info, "cluster_security_group_additional_rules")
        coredns_config = lookup(local.workspace.eks.k8s_info, "coredns_config")
        ecr_names = lookup(local.workspace.eks.k8s_info, "ecr_names")

        prefix = "${local.workspace.eks.project}-${local.workspace.environment}-${var.region}"
        eks_access_entries = flatten([for k, v in local.workspace.eks.k8s_info.eks_access_entries : [for s in v.user_arn : { username = s, access_policy = lookup(local.workspace.eks.eks_access_policy, k), group = k }]])

        eks_access_policy = {
          viewer = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSViewPolicy",
          admin  = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
        }
        project    = "storio"
        account_id = data.aws_caller_identity.current.account_id
 
        
      }
      

    }

    
  }
  workspace = local.env[terraform.workspace]
}