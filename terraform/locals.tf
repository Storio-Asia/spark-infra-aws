locals {
  env = {
    
    
    tags = {

        Project = "Spark"
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
        name = "spark-storio-dev-eks-cluster"
        kubernetes_version = "1.33"
        enable_cluster_creator_admin_permissions = false
        #subnet_ids = [for subnet in aws_subnet.app : subnet.id]
        endpoint_public_access = true
        endpoint_private_access = true
        create_cloudwatch_log_group = false # for dev enviornment
        enable_log_types = [] # do not enable control plane logs        
       
        eks_managed_node_groups = {
         dev-ng = {
            # Starting on 1.30, AL2023 is the default AMI type for EKS managed node groups
            #ami_type       = "AL2023_x86_64_STANDARD"
            #create_security_group = true
            iam_role_additional_policies = {
              ssm_access        = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
              cloudwatch_access = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
              service_role_ssm  = "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM"
              default_policy    = "arn:aws:iam::aws:policy/AmazonSSMManagedEC2InstanceDefaultPolicy"
            }
            instance_types = ["t3.large"]

            min_size     = 1
            max_size     = 5
            desired_size = 1
            
          }
        }

        eks_access_entries = {
          viewer = {
            user_arn = []
          }
          admin = {
            user_arn = [
              "arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/hbsheikh",
              "arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/sohaib"
              ]
          }
        }

        eks_access_policy = {
          viewer = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSViewPolicy",
          admin  = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
        }
      }

     

    } # End of DEV block

    
  }
  workspace = local.env[terraform.workspace]

}


