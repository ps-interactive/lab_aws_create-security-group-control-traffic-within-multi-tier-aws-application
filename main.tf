# REGION HARDCODED
# todo fix provider version references per https://www.terraform.io/docs/configuration/provider-requirements.html
provider "aws" {
  region  = "us-west-2"
}
# provider "cloudinit" {
#   version = "~> 2.1"
# }
# provider "local" {
#   version = "~> 2.0"
# }

# data "aws_region" "current" {
#   provider = aws.region
# }
terraform {
  required_providers {
    aws = {
      version = "~> 3.7"
    }
    cloudinit = {
      version = "~> 2.1"
    }
    local = {
      version = "~> 2.0"
    }
    tls = {
      version = "~> 3.0"
    }
    random = {
      version = "~> 3.0"
    }
  }
}