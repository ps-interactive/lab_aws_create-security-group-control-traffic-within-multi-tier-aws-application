
variable "jumpbox_subnet_id" {
  type    = string
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
data "cloudinit_config" "jumpbox_inline" {
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
data "local_file" "jumpbox_shell_script" {
  filename = "${path.module}/cloud-init-jumpbox.sh"
}

data "cloudinit_config" "jumpbox_config_script" {
  gzip          = true
  base64_encode = true

  part {
    content_type = "text/x-shellscript"
    content      = data.local_file.jumpbox_shell_script.content
  }
}






###############################
# SECURITY
###############################


resource "aws_security_group" "ssh-access" {
  name        = "ssh-sg"
  description = "Allow SSH traffic"
  vpc_id      = aws_vpc.lab.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.cidr_block_world] #accessible from world
    #cidr_blocks = data.aws_ip_ranges.ec2-connect-usw2.cidr_blocks #accessible from EC2-Connect only

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
  ami                    = data.aws_ami.amazon_linux_v2.id
  instance_type          = var.jumpbox_instance_type
  monitoring             = false
  vpc_security_group_ids = [aws_security_group.ssh-access.id]
  user_data              = data.cloudinit_config.jumpbox_config_script.rendered
  key_name               = aws_key_pair.terrakey.key_name
  # put in jumpbox subnet
  subnet_id = aws_subnet.jumpbox_subnet.id
  # Add private key file so jumpbox can access other vms
  # todo: doable via cloudinit? https://stackoverflow.com/a/62105461/2934158
  provisioner "file" {
    content     = tls_private_key.pki.private_key_pem
    destination = "$HOME/.ssh/id_rsa_ec2"

    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = tls_private_key.pki.private_key_pem
      host        = aws_instance.jumpbox_server.public_ip
    }
  }
  # fix key permissions
  provisioner "remote-exec" {
    inline = [
      "chmod 600 ~/.ssh/id_rsa_ec2"
    ]
    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = tls_private_key.pki.private_key_pem
      host        = aws_instance.jumpbox_server.public_ip
    }
  }
  tags = {
    Name = "jumpbox"
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

# output "ssh_command_out" {
#   value = format("%s@%s -i %s","ec2-user",aws_instance.jumpbox_server.*.public_dns,  data.terrakey_private.filename )
# }
#  ssh ec23-user@ec2-35-164-221-205.us-west-2.compute.amazonaws.com -i .\src\lab-ec2.key
