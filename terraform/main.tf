data "aws_availability_zones" "available" {
  state = "available"
}

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
        "Name" = "${local.workspace.client}-${local.workspace.environment}-web-subnet"
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
  route_table_id         = aws_route_table.db-rt
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

  tags = merge(local.env.tags,
    {
        Name = "${local.workspace.client}-${local.workspace.environment}-public-RDSInstance"
    }
  )
}

################################################### RDS Instance deployment end ##########################################