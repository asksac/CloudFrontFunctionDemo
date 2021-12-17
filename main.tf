data "aws_caller_identity" "current_account_id" {
}

locals {
  account_id              = data.aws_caller_identity.current_account_id.account_id

  # Common tags to be assigned to all resources
  common_tags             = {
    Project               = "Demo Website on CloudFront - ${var.aws_env} Site"
    Application           = var.app_name 
    Environment           = var.aws_env
  }
}
