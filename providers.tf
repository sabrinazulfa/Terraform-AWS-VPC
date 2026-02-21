terraform {
  required_version = ">= 0.13.7"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.0"
    }
  }
}
provider "aws" {
  region = local.region
  access_key = local.dev_aws_key
  secret_key = local.dev_aws_secret
}