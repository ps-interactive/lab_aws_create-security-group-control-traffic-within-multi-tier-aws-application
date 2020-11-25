
# Lab VPC
resource "aws_vpc" "lab_vpc" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "Lab VPC"
  }
}

# external web subnet, load balancers
resource "aws_subnet" "external_web_subnet" {
  vpc_id                  = aws_vpc.lab_vpc.id
  cidr_block              = "10.0.10.0/24"
  map_public_ip_on_launch = true
  
  tags = {
    Name = "External Web Subnet"
  }  
}

# internal web subnet, web servers
resource "aws_subnet" "internal_web_subnet" {
  vpc_id                  = aws_vpc.lab_vpc.id
  cidr_block              = "10.0.20.0/24"
  map_public_ip_on_launch = false

  tags = {
    Name = "Internal Web Subnet"
  }  
}

# internal db subnet, db servers
resource "aws_subnet" "internal_db_subnet" {
  vpc_id                  = aws_vpc.lab_vpc.id
  cidr_block              = "10.0.30.0/24"
  map_public_ip_on_launch = false

  tags = {
    Name = "Internal DB Subnet"
  }  
}

# internal management subnet, jumpbox or bastion servers
resource "aws_subnet" "jumpbox_subnet" {
  vpc_id                  = aws_vpc.lab_vpc.id
  cidr_block              = "10.0.100.0/24"
  map_public_ip_on_launch = true #required for ec2-connect?

  tags = {
    Name = "Jumpbox Subnet"
  }  
}
