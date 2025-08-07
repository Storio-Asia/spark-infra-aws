resource "aws_efs_file_system" "this" {
  creation_token = var.token
  performance_mode = "generalPurpose"
  throughput_mode = "bursting"
  encrypted = true
  tags = var.tags
}

