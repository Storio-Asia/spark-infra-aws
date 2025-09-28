# Storio Spark 
This repository contains Terraform code to provision and manage Spark infrastructure on AWS, including networking,S3 storage, EFS, EKS Cluster and RDS Instance.

## Project Structure
- **terraform/**: Main Terraform configuration and modules
    - **modules/**: Reusable Terraform modules for Databricks and AWS resources
- **.github/workflows/**: CI/CD workflows for infrastructure deployment
    - **workflow.yaml**: Applies changes to on push to main branch
    - **terraform-destroy.yaml**: Manual workflow for infrastructure teardown

