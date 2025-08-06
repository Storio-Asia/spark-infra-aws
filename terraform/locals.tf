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
  
        # Global variables
        cluster_name                   = "storio-dev-eks-cluster"
        #env                            = "default"
        #region                         = local.env.aws_region
        #vpc_id                         = aws_vpc.this.id #"vpc-02af529e05c41b6bb"
        #vpc_cidr                       = local.workspace.cidr_block
        #public_subnet_ids              = [for subnet in aws_subnet.app : subnet.id] #["subnet-09aeb297a112767b2", "subnet-0e25e76fb4326ce99"]
        cluster_version                = "1.33"
        cluster_endpoint_public_access = true
        #ecr_names                      = ["codedevops"]

        # EKS variables
        

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

    } ### ebd of DEV environment

    
  }
  workspace = local.env[terraform.workspace]
}