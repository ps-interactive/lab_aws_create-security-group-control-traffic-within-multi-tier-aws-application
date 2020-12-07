# Get latest Amazon Linux 2 AMI
# data "aws_ami" "amazon_linux_v2" {
#   most_recent = true
#   owners      = ["amazon"]
#   filter {
#     name   = "name"
#     values = ["amzn2-ami-hvm*"]
#   }
# }

data "aws_ami" "amazon_linux_v2" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-2*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["137112412989"] # Amazon

}

####################
# RESOURCE OUTPUTS
####################


# VPC
output "vpc_id_out" {
  value = aws_vpc.lab.id
}

output "vpc_arn_out" {
  value = aws_vpc.lab.arn
}

# AMI

output "ami_id_out" {
  value = data.aws_ami.amazon_linux_v2.id
}

output "ami_arn_out" {
  value = data.aws_ami.amazon_linux_v2.arn
}

output "ami_description_out" {
  value = data.aws_ami.amazon_linux_v2.description
}


output "ami_kernel_id_out" {
  value = data.aws_ami.amazon_linux_v2.kernel_id
}

output "ami_product_codes_out" {
  value = data.aws_ami.amazon_linux_v2.product_codes
}
