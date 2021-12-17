terraform {
  required_version        = ">= 0.12"
  required_providers {
    aws = {
      source              = "hashicorp/aws"
      version             = ">= 3.69.0"
    } 
    archive = {
      source              = "hashicorp/archive"
      version             = ">= 2.2.0" 
    } 
    null = {
      source              = "hashicorp/null"
      version             = ">= 3.1.0" 
    } 
  }
}

provider "aws" {
  profile                 = var.aws_profile
  region                  = var.aws_region
}
