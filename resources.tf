# Get latest Amazon Linux 2 AMI
data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*"]
  }
}

####################
# RESOURCE OUTPUTS
####################


output "ami_id_out" {
  value = data.aws_ami.amazon_linux_2.id
}

output "ami_arn_out" {
  value = data.aws_ami.amazon_linux_2.arn
}

output "ami_description_out" {
  value = data.aws_ami.amazon_linux_2.description
}


output "ami_kernel_id_out" {
  value = data.aws_ami.amazon_linux_2.kernel_id
}

output "ami_product_codes_out" {
  value = data.aws_ami.amazon_linux_2.product_codes
}
