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
      account_id = data.aws_caller_identity.current.account_id
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
  
        # Global variables
        k8s_info = lookup(var.eks_env,local.env.environment)
        name                   = lookup(k8s_info,"cluster_name")
        #env                            = "default"
        #region                         = local.env.aws_region --> this default to provider region which will be passed as variable when terraform is initialised
        #vpc_id                         = aws_vpc.this.id
        #subnet_ids = [for subnet in aws_subnet.app : subnet.id]
        kubernetes_version                = lookup(k8s_info,"cluster_version ")
        endpoint_public_access = lookup(k8s_info,"cluster_endpoint_public_access")
        #ecr_names                      = ["codedevops"]

        cloudwatch_log_group_retention_in_days = lookup(k8s_info,"cloudwatch_log_group_retention_in_days")
        create_node_iam_role = lookup(k8s_info,"create_node_iam_role")
        enable_cluster_creator_admin_permissions = lookup(k8s_info,"enable_cluster_creator_admin_permissions")
        #cni_service_account_role_arn = aws_iam_role.vpc_cni.arn
        
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
        
        cluster_security_group_additional_rules = lookup(k8s_info,"cluster_security_group_additional_rules")
        enabled_log_types = lookup(k8s_info,"enable)log_types")        
        node_security_group_additional_rules = lookup(k8s_info,"node_security_group_additional_rules")
        coredns_config = lookup(k8s_info,"coredns_config")
        eks_access_policy = {
          viewer = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSViewPolicy",
          admin  = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
        }


        access_entries = flatten([for k,v in local.k8s_info.access_entries : [for s in v.user_arn : {username = s, access_policy = lookup(local.dev.eks_access_policy, k), group = k}]])
      } # ## end of EKS DEV environment

    } # End of DEV block

    
  }
  workspace = local.env[terraform.workspace]
}