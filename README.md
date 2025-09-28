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

### Infrastructure Cleanup
- **Trigger**: Manual workflow dispatch
- **Steps**:
  1. Terraform initialization
  2. Automated destroy with approval

### Root Infrastructure
| Resource | Purpose |
|---|---|
|aws_vpc.this | VPC |
|aws_subnet.web | Web subnets for Load balancer |
|aws_route_table.web-rt |  Route table for web subnet |
|aws_route_table_assocation.app | Route table assocation with web subnets |
|aws_subnet.app | Web subnets for eks cluster deployment |
|aws_route_table.app-rt |  Route table for app subnet |
|aws_route_table_assocation.app | Route table assocation with app subnets |
|aws_subnet.db | DB subnets for RDS |
|aws_route_table.db-rt |  Route table for db subnet |
|aws_route_table_assocation.db | Route table assocation with db subnets |
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

### RDS
| Resource | Purpose |
|---|---|
|aws_db_instance.mysql| MySQL RDS Instance|

### IAM Role and policies
| Resource | Purpose |
|---|---|
|aws_iam_role.aws_flow_logs_role| VPC flow logs role|
|aws_iam_policy.vpc_flow_logs_policy| VPC flow logs policy|
|aws_iam_role_policy_attachment.vpc_flow_logs_role_policy_attachment| VPC flow logs policy attachment|
|aws_iam_policy.node_efs_policy| NODE policy to allow access to EFS file share|

### S3 Storage
|Resource| Purpose|
|---|---|
|aws_s3_bucket.spark-dev-bucket| S3 Storage|

### EKS Cluster
| Resource | Purpose |
|---|---|
| eks | EKS cluster for running Storio application |

### ELB Controller
| Resrouce | Purpose|
|---|---|
| elb | Installs AWS Elastic load balancer controllers on the EKS cluster |

### Autoscaler
| Resrouce | Purpose|
|---|---|
| eksautoscaler | Setups EKS autoscaler for pods scalling functionality |

### EFS file system
| Resrouce | Purpose|
|---|---|
| efs | NFS file system share for EKS cluster to use |

### Modules Description

### eks
- Deploys AWS EKS cluster
- Configure EKS cluster to deployment to app subnets
- Setup logs
- setup EKS Access entries
- Configure cloudwatch logs group
- Sets up and configures eks managed node group

### efs
- Deploys AWS EFS file system

### awsloadbalancerController
- Deploys AWS Load balancer controller in EKS cluster using helm provider
- Configure iam role and policy for controller to use
- Configures service account 

### EKSClusterAutoSclaer
- Deploys AWS EKS cluster Auto scaler using helm provider
- Configure iam role and policy for cluster autoscaler to use
- confgiures service account

