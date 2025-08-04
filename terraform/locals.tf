locals {
  env = {
    aws_region = "ap-southeast-5"
    
    tags = {
        Repository = ""
        Environment = "dev"
        Project = ""
               
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

      mysql_instance = {
        allocated_storage = 10
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
      

      

    }

    
  }
  workspace = local.env[terraform.workspace]
}