# REGION HARDCODED
provider "aws" {
  version = "~> 3.7"  
  region = "us-west-2"
}
provider "cloudinit" {
  version = "~> 2.1"  
}
provider "local" {
  version = "~> 2.0"  
}

