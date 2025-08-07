eks_env = {
  dev = {
    # Global variables
    cluster_name                   = "storio-dev-eks-cluster"
    env                            = "dev"
    cluster_version                = "1.33"
    cluster_endpoint_public_access = true
    enable_cluster_creator_admin_permissions = false

    # EKS variables
    create_node_iam_role = true
    cloudwatch_log_group_retention_in_days = 30
    node_security_group_additional_rules =  {

          
            allow_all_egress = {
              type        = "egress"
              description = "allow all outbound"
              from_port   = 0
              to_port     = 0
              protocol    = "-1"
              cidr_blocks = ["0.0.0.0/0"]
            }
          
        }
    #cluster_security_group_additional_rules = {}

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
            "arn:aws:iam::483898562597:root",
            "arn:aws:iam::483898562597:user/hbsheikh",
            "arn:aws:iam::483898562597:user/sohaib"
            ]
      }
    }
    # EKS Addons variables 
    coredns_config = {
      replicaCount = 1
    }
  }

}