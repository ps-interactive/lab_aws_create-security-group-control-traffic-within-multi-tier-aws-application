# ami for amazon hvm version 2
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
