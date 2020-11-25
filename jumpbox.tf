# variables, outside dependencies
# variable "vpc_id" {
#   type = string
#   default = "aws_vpc.lab_vpc.id"
# }
variable "jumpbox_subnet_id" {
  type = string
  default = "aws_subnet.jumpbox_subnet.id"
}



###############################
# JUMPBOX EC2 CONFIG DATA
###############################



# Restrict to EC2 Instance Connect from us-west-2
data "aws_ip_ranges" "ec2-connect-usw2" {
  regions  = ["us-west-2"]
  services = ["ec2_instance_connect"]
}

# Restrict to all AMAZON from us-west-2
data "aws_ip_ranges" "amazon-usw2" {
  regions  = ["us-west-2"]
  services = ["amazon"]
}

# cloudinit to add bash commands and powershell
data "cloudinit_config" "install-requirements-config-inline" {
  gzip          = true
  base64_encode = true

  part {
    content_type = "text/x-shellscript"
    content      = <<-EOF
          #!/bin/bash
          echo "end of config inline"
        EOF
  }
}

# cloudinit script
data "local_file" "shell_script" {
  filename = "${path.module}/cloud-init-script.sh"
}

data "cloudinit_config" "install-requirements-config-script" {
  gzip          = true
  base64_encode = true

  part {
    content_type = "text/x-shellscript"
    content      = data.local_file.shell_script.content
  }
}


###############################
# SECURITY
###############################


resource "aws_security_group" "ssh-access" {
  name        = "ssh-security-group"
  description = "Allow SSH traffic"
  vpc_id      = aws_vpc.lab_vpc.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    #cidr_blocks = [var.cidr_block_world] #accessible from world
    cidr_blocks = data.aws_ip_ranges.ec2-connect-usw2.cidr_blocks #accessible from EC2-Connect only

  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.cidr_block_world]
    #cidr_blocks = data.aws_ip_ranges.amazon-usw2.cidr_blocks #fails, too many ranges

  }

  tags = {
    Name = "SSH Only"
  }
}

####################
# INSTANCE
####################

resource "aws_instance" "jumpbox_server" {
  ami                    = data.aws_ami.amazon_linux_2.id
  instance_type          = "t2.small"
  monitoring             = false
  vpc_security_group_ids = [aws_security_group.ssh-access.id]
  user_data              = data.cloudinit_config.install-requirements-config-script.rendered
  # put in jumpbox subnet
  subnet_id = aws_subnet.jumpbox_subnet.id
  tags = {
    Name = "Jumpbox Server"
  }
}

####################
# JUMPBOX OUTPUTS
####################


output "public_ip_out" {
  value = aws_instance.jumpbox_server.*.public_ip
}
output "public_dns_out" {
  value = aws_instance.jumpbox_server.*.public_dns
}
