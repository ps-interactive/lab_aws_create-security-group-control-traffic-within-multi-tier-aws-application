
# cloudinit to add bash commands and powershell
data "cloudinit_config" "web_inline" {
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
data "local_file" "web_shell_script" {
  filename = "${path.module}/cloud-init-web.sh"
}

data "cloudinit_config" "web_config_script" {
  gzip          = true
  base64_encode = true

  part {
    content_type = "text/x-shellscript"
    content      = data.local_file.web_shell_script.content
  }
}


resource "aws_instance" "web_tier" {
  for_each          = var.web_subnets
  ami               = data.aws_ami.amazon_linux_v2.id
  instance_type     = var.web_instance_type
  availability_zone = each.key
  subnet_id         = aws_subnet.web_subnets[each.key].id
  key_name          = aws_key_pair.terrakey.key_name
  # iam_instance_profile = aws_iam_instance_profile.bastion_profile.name
  security_groups = [aws_security_group.ssh-access.id]
  user_data              = data.cloudinit_config.web_config_script.rendered

  tags = {
    Name        = "web-server-${upper(replace(each.key, "us-west-2", ""))}" #hard code?
    Description = "Web Server In ${each.key}"
  }
}

