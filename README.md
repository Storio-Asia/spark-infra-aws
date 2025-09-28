# Storio Spark 
This repository contains Terraform code to provision and manage Spark infrastructure on AWS, including networking,S3 storage, EFS, EKS Cluster and RDS Instance.

## Project Structure
- **terraform/**: Main Terraform configuration and modules
    - **modules/**: Reusable Terraform modules for Databricks and AWS resources
- **.github/workflows/**: CI/CD workflows for infrastructure deployment
    - **workflow.yaml**: Applies changes to on push to main branch
    - **terraform-destroy.yaml**: Manual workflow for infrastructure teardown

## CI/CD Workflows
- **Trigger**: Push to main branch
- **Steps**:
  1. Configure AWS Credentials
  2. Setup Terraform
  3. Terraform plan 
  4. Manual Approval
  5. Terraform Apply

### Root Infrastructure
| Resource | Purpose |
|---|---|
| aws_vpc.this | VPC |
| aws_subnet.web | Web subnets for Load balancer |
| aws_route_table.web-rt |  Route table for web subnet |
| aws_route_table_assocation.app | Route table assocation with web subnets |
| aws_subnet.app | Web subnets for eks cluster deployment |
| aws_route_table.app-rt |  Route table for app subnet |
| aws_route_table_assocation.app | Route table assocation with app subnets |
| aws_subnet.db | DB subnets for RDS |
| aws_route_table.db-rt |  Route table for db subnet |
| aws_route_table_assocation.db | Route table assocation with db subnets |
|aws_route.db_internet_route| route to allow RDS instance internet access. This was requried for developers access|
|aws_network_acl.web|Web subnet NACL|
|aws_network_acl.app| App NACL|
|aws_network_acl.db|DB subnet NACL|
|aws_network_acl_rule.web_nacl_rules| Ruleset for Web NACL|
|aws_network_acl_rule.app_nacl_rules| Ruleset for App NACL|
|aws_network_acl_rule.db_nacl_rules| Ruleset for DB NACL|
|aws_internet_gateway.igw| Internet Gateway for internet connectvitiy|
|aws_eip.nat_eip| Nat Gateway Elastic ip address|
|aws_nat_gateway.this| NAT gateway to provide internet connectivity for private subnets such as app Db|
|aws_route.app_internet_route| Internet route for app subnets|
|aws_security_group.rds_sg| RDS security group|
|aws_db_subnet_group.rds_subnet_group| Subnet Group to deploy RDS Instance|
|aws_db_instance.mysql| MySQL RDS Instance|

### IAM Role and policies
|Resource|Purpose|
|---|---|
|aws_iam_role.aws_flow_logs_role| VPC flow logs role|
|aws_iam_policy.vpc_flow_logs_policy| VPC flow logs policy|
|aws_iam_role_policy_attachment.vpc_flow_logs_role_policy_attachment| VPC flow logs policy attachment|
|aws_iam_policy.node_efs_policy| NODE policy to allow access to EFS file share|

### S3 Storage
|Resource| Purpose|
|---|---|
|aws_s3_bucket.spark-dev-bucket| S3 Storage|
|module eks|EKS cluster|
|||
| aws_s3_bucket_public_access_block.root_storage_bucket | Public access block for root bucket |
| aws_s3_bucket_policy.root_bucket_policy | Policy for root bucket |
| aws_kms_key.workspace_storage | KMS key for workspace storage |
| aws_kms_alias.workspace_storage_key_alias | Alias for workspace storage key |
| aws_kms_key.managed_services | KMS key for managed services |
| aws_kms_alias.managed_services_key_alias | Alias for managed services key |
| aws_kms_key.catalog_storage | KMS key for catalog storage |
| aws_kms_alias.catalog_storage_key_alias | Alias for catalog storage key |
