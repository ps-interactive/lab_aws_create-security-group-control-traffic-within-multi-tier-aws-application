
# Lab VPC
resource "aws_vpc" "lab" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"
  enable_dns_hostnames = true
  tags = {
    Name = "Lab VPC"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.lab.id

  tags = {
    Name = "Internet Gateway for Lab VPC"
  }
}

# Public Route table
resource "aws_route_table" "public_route" {
  vpc_id = aws_vpc.lab.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "Public Route Table"
  }
}
# Private Route table
resource "aws_default_route_table" "private_route" {
  default_route_table_id = aws_vpc.lab.default_route_table_id

  tags = {   
    Name = "Private Route Table"
  } 
} 

# # external web subnet, load balancers
# resource "aws_subnet" "load_balancer_subnet" {
#   vpc_id                  = aws_vpc.lab.id
#   cidr_block              = "10.0.10.0/24"
#   map_public_ip_on_launch = true
  
#   tags = {
#     Name = "External Load Balancer Subnet"
#   }  
# }

# # SINGLE internal web subnet, web servers
# resource "aws_subnet" "internal_web_subnet" {
#   vpc_id                  = aws_vpc.lab.id
#   cidr_block              = "10.0.20.0/24"
#   map_public_ip_on_launch = false

#   tags = {
#     Name = "Internal Web Subnet"
#   }  
# }

# SET OF WEB TIER SUBNETS
resource "aws_subnet" "web_subnets" {
  for_each                = var.web_subnets
  vpc_id                  = aws_vpc.lab.id
  cidr_block              = each.value
  map_public_ip_on_launch = false
  availability_zone       = each.key
  tags = {
    Name = "Internal Web Subnet"
  }    
}

# internal db subnet, db servers
resource "aws_subnet" "internal_db_subnet" {
  vpc_id                  = aws_vpc.lab.id
  cidr_block              = "10.0.30.0/24"
  map_public_ip_on_launch = false

  tags = {
    Name = "Internal DB Subnet"
  }  
}

# internal management subnet, jumpbox or bastion servers
resource "aws_subnet" "jumpbox_subnet" {
  vpc_id                  = aws_vpc.lab.id
  cidr_block              = "10.0.100.0/24"
  map_public_ip_on_launch = true #required for ec2-connect?

  tags = {
    Name = "Jumpbox Subnet"
  }  
}

# Associate management Subnet with Public Route Table
resource "aws_route_table_association" "public_subnet_assoc" {
  count          = 2
  route_table_id = aws_route_table.public_route.id
  subnet_id      = aws_subnet.jumpbox_subnet.id
  depends_on     = [aws_route_table.public_route, aws_subnet.jumpbox_subnet]
}