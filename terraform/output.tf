output "vpcid" {
    value = aws_vpc.this.id
}

output "rds"{
    value = aws_db_instance.mysql.endpoint
    description = "DNS address of RDS insance"
}

