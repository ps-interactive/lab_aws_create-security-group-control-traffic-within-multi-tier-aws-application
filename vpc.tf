
# Lab VPC
resource "aws_vpc" "lab" {
  cidr_block           = "10.0.0.0/16"
  instance_tenancy     = "default"
  enable_dns_hostnames = true
  tags = {
    Name = "Lab VPC"
  }
  #enable_s3_endpoint = true   #enable yum update via s3? https://aws.amazon.com/premiumsupport/knowledge-center/ec2-al1-al2-update-yum-without-internet/
}

# PUBLIC
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

# SET OF PUBLIC SUBNETS
resource "aws_subnet" "public_subnets" {
  for_each                = var.public_subnets
  vpc_id                  = aws_vpc.lab.id
  cidr_block              = each.value
  map_public_ip_on_launch = false
  availability_zone       = each.key
  tags = {
    Name = "External Public Subnet ${upper(replace(each.key, "us-west-2", ""))}"
  }
}
resource "aws_subnet" "public" {
  #availability_zone = data.aws_availability_zones.available.names[0]
  cidr_block = "10.0.2.0/24"
  vpc_id     = aws_vpc.lab.id
  tags = {
    "Name" = "Subnet NAT"
  }
}


# Associate public route to public subnet
resource "aws_route_table_association" "public_route" {
  for_each       = var.public_subnets
  route_table_id = aws_route_table.public_route.id
  subnet_id      = aws_subnet.public_subnets[each.key].id
}

# NAT
# NAT GATEWAY SO Private instances can access outside
# refer https://dev.betterdoc.org/infrastructure/2020/02/04/setting-up-a-nat-gateway-on-aws-using-terraform.html

resource "aws_eip" "nat_gateway" {
  vpc = true
}

resource "aws_nat_gateway" "nat_gateway" {
  allocation_id = aws_eip.nat_gateway.id
  subnet_id     = aws_subnet.public.id
  tags = {
    "Name" = "NAT Gateway"
  }
}


output "nat_gateway_ip" {
  value = aws_eip.nat_gateway.public_ip
}

# PRIVATE
# Private Route table
resource "aws_route_table" "private_route" {
  #default_route_table_id = aws_vpc.lab.default_route_table_id
  vpc_id = aws_vpc.lab.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gateway.id
  }
  tags = {
    Name = "Private Route Table, use NAT"
  }
}
# make this private route the main route
resource "aws_main_route_table_association" "a" {
  vpc_id         = aws_vpc.lab.id
  route_table_id = aws_route_table.private_route.id
}



# SET OF WEB TIER SUBNETS
resource "aws_subnet" "web_subnets" {
  for_each                = var.web_subnets
  vpc_id                  = aws_vpc.lab.id
  cidr_block              = each.value
  map_public_ip_on_launch = false
  availability_zone       = each.key
  tags = {
    Name = "Internal Web Subnet ${upper(replace(each.key, "us-west-2", ""))}"
  }
}
# Associate web subnet with private route and NAT# 
resource "aws_route_table_association" "web_subnets" {
  for_each       = var.web_subnets
  route_table_id = aws_route_table.private_route.id
  subnet_id      = aws_subnet.web_subnets[each.key].id
}
# internal db subnet, db servers
resource "aws_subnet" "db_subnet" {
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
resource "aws_route_table_association" "jumpbox_public_subnet_assoc" {
  route_table_id = aws_route_table.public_route.id
  subnet_id      = aws_subnet.jumpbox_subnet.id
}

# Associate NAT subnet (which is in the 'public' subnet) with Public Route Table
# per guidance at top of https://aws.amazon.com/premiumsupport/knowledge-center/ec2-access-internet-with-NAT-gateway/
resource "aws_route_table_association" "public_subnet_assoc" {
  route_table_id = aws_route_table.public_route.id
  subnet_id      = aws_subnet.public.id
}


