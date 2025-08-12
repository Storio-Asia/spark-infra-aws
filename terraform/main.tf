

resource "aws_vpc" "this" {
  cidr_block = local.workspace.cidr_block
  enable_dns_hostnames = "true"
  enable_dns_support   = "true"
  tags = merge(
    local.env.tags,
    {
        "Name" = "${local.workspace.client}-${local.workspace.environment}"
    }
  )
}

resource "aws_subnet" "web" {
  count = length(local.workspace.subnets.web)
  vpc_id = aws_vpc.this.id
  cidr_block = local.workspace.subnets.web[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true
  tags = merge(
    local.env.tags,
    {
        "Name" = "${local.workspace.client}-${local.workspace.environment}-web-subnet",
        "kubernetes.io/role/elb" = "1"
    }
  )
}

resource "aws_route_table" "web-rt" {
  vpc_id = aws_vpc.this.id
  tags = merge(
    local.env.tags,
    {
      "Name" = "${local.workspace.environment}-subnet-web-rt"
    }
  )
}

resource "aws_route_table_association" "web" {
  count = length(aws_subnet.web)

  subnet_id      = aws_subnet.web[count.index].id
  route_table_id = aws_route_table.web-rt.id
}

resource "aws_subnet" "app" {
  count = length(local.workspace.subnets.app)
  vpc_id = aws_vpc.this.id
  cidr_block = local.workspace.subnets.app[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]
  tags = merge(
    local.env.tags,
    {
        "Name" = "${local.workspace.client}-${local.workspace.environment}-app-subnet"
    }
  )
}

resource "aws_route_table" "app-rt" {
  vpc_id = aws_vpc.this.id
  tags = merge(
    local.env.tags,
    {
      "Name" = "${local.workspace.client}-${local.workspace.environment}-subnet-app-rt"
    }
  )
}

resource "aws_route_table_association" "app" {
  count = length(aws_subnet.app)

  subnet_id      = aws_subnet.app[count.index].id
  route_table_id = aws_route_table.app-rt.id
}


resource "aws_subnet" "db" {
  count = length(local.workspace.subnets.db)
  vpc_id = aws_vpc.this.id
  cidr_block = local.workspace.subnets.db[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true
  tags = merge(
    local.env.tags,
    {
        "Name" = "${local.workspace.client}-${local.workspace.environment}-db-subnet"
    }
  )
}

resource "aws_route_table" "db-rt" {
  vpc_id = aws_vpc.this.id
  tags = merge(
    local.env.tags,
    {
      "Name" = "${local.workspace.client}-${local.workspace.environment}-subnet-db-rt"
    }
  )
}

resource "aws_route" "db_internet_route" {
  route_table_id         = aws_route_table.db-rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_route_table_association" "db" {
  count = length(aws_subnet.db)

  subnet_id      = aws_subnet.db[count.index].id
  route_table_id = aws_route_table.db-rt.id
}

resource "aws_route" "web_defaultroute" {
  route_table_id         = aws_route_table.web-rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id     = aws_internet_gateway.igw.id
  }


resource "aws_network_acl" "web" {
  
  vpc_id = aws_vpc.this.id
  tags = merge(
    local.env.tags,
    {
      "Name" = "${local.workspace.client}-${local.workspace.environment}-subnet-web-nacl"
    }
  )
}

resource "aws_network_acl_association" "web" {
  count = length(aws_subnet.web)

  network_acl_id = aws_network_acl.web.id
  subnet_id      = aws_subnet.web[count.index].id
}

resource "aws_network_acl" "app" {
  
  vpc_id = aws_vpc.this.id
  tags = merge(
    local.env.tags,
    {
      "Name" = "${local.workspace.client}-${local.workspace.environment}-subnet-app-nacl"
    }
  )
}

resource "aws_network_acl_association" "app" {
  count = length(aws_subnet.app)

  network_acl_id = aws_network_acl.app.id
  subnet_id      = aws_subnet.app[count.index].id
}

resource "aws_network_acl" "db" {
  
  vpc_id = aws_vpc.this.id
  tags = merge(
    local.env.tags,
    {
      "Name" = "${local.workspace.client}-${local.workspace.environment}-subnet-db-nacl"
    }
  )
}

resource "aws_network_acl_association" "db" {
  count = length(aws_subnet.db)

  network_acl_id = aws_network_acl.db.id
  subnet_id      = aws_subnet.db[count.index].id
}



resource "aws_network_acl_rule" "web_nacl_rules" {
  for_each = { for rule in local.workspace.web_nacl_rules : "${rule.rule_number}-${rule.egress}" => rule }

  network_acl_id = aws_network_acl.web.id
  rule_number    = each.value.rule_number
  egress         = each.value.egress
  protocol       = each.value.protocol
  rule_action    = each.value.rule_action
  cidr_block     = each.value.cidr_block
  from_port      = lookup(each.value, "from_port", null)
  to_port        = lookup(each.value, "to_port", null)
}


resource "aws_network_acl_rule" "app_nacl_rules" {
  for_each = { for rule in local.workspace.app_nacl_rules : "${rule.rule_number}-${rule.egress}" => rule }

  network_acl_id = aws_network_acl.app.id
  rule_number    = each.value.rule_number
  egress         = each.value.egress
  protocol       = each.value.protocol
  rule_action    = each.value.rule_action
  cidr_block     = each.value.cidr_block
  from_port      = lookup(each.value, "from_port", null)
  to_port        = lookup(each.value, "to_port", null)
}


resource "aws_network_acl_rule" "db" {
  for_each = { for rule in local.workspace.db_nacl_rules : "${rule.rule_number}-${rule.egress}" => rule }

  network_acl_id = aws_network_acl.db.id
  rule_number    = each.value.rule_number
  egress         = each.value.egress
  protocol       = each.value.protocol
  rule_action    = each.value.rule_action
  cidr_block     = each.value.cidr_block
  from_port      = lookup(each.value, "from_port", null)
  to_port        = lookup(each.value, "to_port", null)
}

resource "aws_internet_gateway" "igw" {

  vpc_id = aws_vpc.this.id
  tags = merge(
    local.env.tags,
    {
        "Name" = "${local.workspace.client}-${local.workspace.environment}-igw"
    }
  )
}

resource "aws_eip" "nat_eip" {
      
      tags = merge(local.env.tags,{
        Name = "nat-eip"
      })
}

resource "aws_nat_gateway" "this" {
  subnet_id = aws_subnet.web[0].id
  allocation_id = aws_eip.nat_eip.id
  tags = merge(local.env.tags,{
    Name = "storio-${local.workspace.environment}-ngw"
  })
}


resource "aws_route" "app_internet_route" {
  route_table_id         = aws_route_table.app-rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_nat_gateway.this.id
}

#################################### my sql rd instance ###########################################

resource "aws_security_group" "rds_sg" {
  
  description = "My SQL RDS SG"
  dynamic "ingress" {
    for_each = local.workspace.db_instance_sgrules.ingress
    content {
      description = ingress.value.description
      from_port = ingress.value.from_port
      to_port = ingress.value.to_port
      protocol = ingress.value.protocol
      cidr_blocks = ingress.value.cidr_block
    }
    
  }
  
  dynamic "egress" {
    for_each = local.workspace.db_instance_sgrules.egress
    content {
      description = egress.value.description
      from_port = egress.value.from_port
      to_port = egress.value.to_port
      protocol = egress.value.protocol
      cidr_blocks = egress.value.cidr_block
    }
  }
  vpc_id = aws_vpc.this.id
  tags = merge(local.env.tags,
    {
       Name = "${local.workspace.client}-${local.workspace.environment}-sg"
    }
  )
}


resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "rds-subnet-group"
  #count = length(aws_subnet.db)
  subnet_ids = [for s in aws_subnet.db: s.id] # this will be used if we would like to deploy multi az rds instance
  #subnet_ids = [aws_subnet.db[0].id, aws_subnet.db[1].id] # first db subnet. Confining it to single AZ .
  tags = merge(local.env.tags,
    {
        Name = "${local.workspace.client}-${local.workspace.environment}-rds-subnetgroupid"
    }
  )
}

resource "aws_db_instance" "mysql" {
  allocated_storage    = local.workspace.mysql_instance.allocated_storage
  engine               = local.workspace.mysql_instance.engine
  engine_version       = "8.0"
  instance_class       = local.workspace.mysql_instance.instance_class
  
  username             = local.workspace.mysql_instance.username
  password             = local.workspace.mysql_instance.password
  publicly_accessible  = local.workspace.mysql_instance.publically_accessible
  skip_final_snapshot  = local.workspace.mysql_instance.skip_final_snapshot
  db_subnet_group_name = aws_db_subnet_group.rds_subnet_group.name
  multi_az = local.workspace.mysql_instance.multi_az
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  identifier = "${local.workspace.client}-${local.workspace.environment}"

  tags = merge(local.env.tags,
    {
        Name = "${local.workspace.client}-${local.workspace.environment}-public-RDSInstance"
    }
  )
}

################################################### RDS Instance deployment end ##########################################

######################## VPC flow logs #############################
resource "aws_iam_role" "vpc_flow_logs_role" {
  name = "VPCFlowLogsRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "vpc-flow-logs.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_policy" "vpc_flow_logs_policy" {
  # checkov:skip=CKV_AWS_355: "Ensure no IAM policies documents allow "*" as a statement's resource for restrictable actions"
  # checkov:skip=CKV_AWS_290: "Ensure IAM policies does not allow write access without constraints"
  name        = "VPCFlowLogsPolicy"
  description = "Policy for VPC Flow Logs to push logs to CloudWatch Logs"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "vpc_flow_logs_role_policy_attachment" {
  policy_arn = aws_iam_policy.vpc_flow_logs_policy.arn
  role      = aws_iam_role.vpc_flow_logs_role.name
}

resource "aws_cloudwatch_log_group" "this" {
  # checkov:skip=CKV_AWS_158: "Ensure that CloudWatch Log Group is encrypted by KMS"
  # checkov:skip=CKV_AWS_338: "Ensure CloudWatch log groups retains logs for at least 1 year"
  name              =  "vpc/flowlogs/spark-storio-dev-${aws_vpc.this.id}"
  retention_in_days = 90
  tags = local.env.tags
}

########### vpc flowlogs ################
resource "aws_flow_log" "local" {
  #count = local.enable_flow_log ? 1 : 0

  iam_role_arn               = aws_iam_role.vpc_flow_logs_role.arn
  log_destination_type       = "cloud-watch-logs"
  log_destination            = aws_cloudwatch_log_group.this.arn
  vpc_id                     = aws_vpc.this.id
  traffic_type = "ALL"

  tags = local.env.tags
}
##########################end vpc flow logs#########################

########### EFS policy will be attached to the workder for mounting of EFS file system ###############
resource "aws_iam_policy" "node_efs_policy" {
  name        = "eks_node_efs_policy"
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

locals {
  flatten_access_entries =  flatten([for k, v in local.workspace.eks.eks_access_entries: [for s in v.user_arn : { username = s, access_policy = lookup(local.workspace.eks.eks_access_policy, k), group = k }]])
  
}

############ S3 bucket ##################

resource "aws_s3_bucket" "spark-dev-bucket" {
  bucket = "storio-spark${local.workspace.environment}-bucket"
  
}

############ EKS Cluster deployment #####################
module "eks"{
  source = "./modules/eks"
  eks_config = merge(local.workspace.eks,
    {
      vpc_id = aws_vpc.this.id
      subnet_ids = [for s in aws_subnet.app : s.id]

      access_entries = {
          for k in local.flatten_access_entries : k.username => {
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

      tags = merge(local.env.tags, 
          {
            Terraform = true
          }
        )

    }
  )
  
}



############# Load balancer module. Sets up ELB, its Iam role, SA account and install it via helm ################################
module "elb"{
  source = "./modules/awsloadbalancerController"
  eks_cluster_name = module.eks.cluster_name
  eks_cluster_endpoint = module.eks.cluster_endpoint
  eks_oidc_issuer_url = module.eks.cluster_oidc_issuer_url
  eks_oidc_provider_arn = module.eks.oidc_provider_arn
  cluster_certificate_authority_data = module.eks.cluster_certificate_authority_data
  vpc_id = aws_vpc.this.id
  providers = {
    kubernetes = kubernetes.k8s
    helm = helm.k8shelm
  }
}

module "eksautoscaler"{
  source = "./modules/EKSClusterAutoScaler"
  eks_cluster_name = module.eks.cluster_name
  eks_cluster_endpoint = module.eks.cluster_endpoint
  eks_oidc_issuer_url = module.eks.cluster_oidc_issuer_url
  eks_oidc_provider_arn = module.eks.oidc_provider_arn
  cluster_certificate_authority_data = module.eks.cluster_certificate_authority_data
   
  providers = {
    kubernetes = kubernetes.k8s
    helm = helm.k8shelm
  }
 
}
############## creating EFS file system (EFS mount targets are created manually as terraform complained about subnet ids provided for mount target since ID of the subnet will not be known at plan time)###################
module efs{
  source = "./modules/efs"
  token = "Spark-${local.workspace.client}-${local.workspace.environment}-token"
  tags = merge(local.env.tags, {
    Name = "Spark-storio-${local.workspace.environment}-efs-filesystem"
  })
  #mount_subnets = [for subnet in aws_subnet.app : subnet.id]
 
}


