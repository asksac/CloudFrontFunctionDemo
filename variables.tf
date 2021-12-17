variable "aws_profile" {
  type                    = string
  default                 = "default"
  description             = "Specify an aws profile name to be used for access credentials (run `aws configure help` for more information on creating a new profile)"
}

variable "aws_region" {
  type                    = string
  default                 = "us-east-1"
  description             = "Specify the AWS region to be used for resource creations"
}

variable "aws_env" {
  type                    = string
  default                 = "dev"
  description             = "Specify a value for the Environment tag"
}

variable "app_name" {
  type                    = string
  description             = "Specify a project name, used primarily for tagging"
}

variable "app_shortcode" {
  type                    = string
  description             = "Specify a short-code or pneumonic for this project, primarily used in naming AWS resources"
}

variable "lambda_function_name" {
  type                    = string 
  default                 = "EchoLambda"
  description             = "Specify name of Lambda function"
}

variable "lambda_api_name" {
  type                    = string 
  default                 = "echo"
  description             = "Specify API resource name to use to map to Lambda function"
}


variable "apigw_stage_name" {
  type                    = string 
  default                 = "$default"
  description             = "Specify stage name for API Gateway deployment"
}

