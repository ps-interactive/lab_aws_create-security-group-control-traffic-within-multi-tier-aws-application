
# cloudinit to add bash commands and powershell
data "cloudinit_config" "install-web-requirements-config-inline" {
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
  user_data       = <<-EOF
#!/bin/bash
yum -y install httpd
echo "<html><head><title>Web Server</title></head><h1>Web X</h1><p>This is the web X server.</p></html>" > /var/www/html/index.html
chmod 644 /var/www/index.html
chown apache.apache /var/www/html/index.html
systemctl enable httpd.service
systemctl start httpd.service
    EOF

  tags = {
    Name        = "web-server-${upper(replace(each.key, "us-west-2", ""))}" #hard code?
    Description = "Web Server In ${each.key}"
  }
}


# # web instance
# resource "aws_web_instance" "lab_rds" {
#   identifier          = "lab-web-instance"
#   instance_class      = "web.t3.micro"
#   allocated_storage   = 10
#   engine              = "mysql"
#   engine_version      = "5.7"
#   name                = "labweb"
#   username            = "labuser"
#   password            = "LabPass20"
#   skip_final_snapshot = true

#   web_subnet_group_name = "web_subnet_group"
# }