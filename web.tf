# variables, outside dependencies
# variable "web_subnet_id" {
#   type = string
#   default = "aws_subnet.internal_web_subnet.id"
# }

# ami for amazon hvm version 2 web server
# Get latest Amazon Linux 2 AMI



# # single web server
# resource "aws_instance" "web_server" {
#   ami                  = data.aws_ami.amazon_linux_v2.id
#   subnet_id            = aws_subnet.web_subnets[0].id
#   instance_type        = "t3.micro"
#   # iam_instance_profile = aws_iam_instance_profile.bastion_profile.name
#   # security_groups      = [aws_security_group.web.id]
#   user_data            = <<-EOF
#       #!/bin/bash
#       yum update -y
#       amazon-linux-extras install -y php7.2
#       yum install -y httpd
#       systemctl start httpd
#       systemctl enable httpd
#       yum install -y git
#       cd /var/www/
#       git clone https://github.com/ps-interactive/lab_aws_create-application-load-balancer-with-http-listener
#       cp -R /var/www/lab_aws_create-application-load-balancer-with-http-listener/carved_rock_site/* /var/www/html/
#     EOF
#   tags = {
#     Name    = "web-server"
#   }
# } 


resource "aws_instance" "web_tier" {
  for_each               = var.web_subnets
  ami                    = data.aws_ami.amazon_linux_v2.id
  instance_type          = var.web_instance_type
  availability_zone      = each.key
  subnet_id              = aws_subnet.web_subnets[each.key].id
  key_name               = aws_key_pair.terrakey.key_name
  # iam_instance_profile = aws_iam_instance_profile.bastion_profile.name
  # security_groups      = [aws_security_group.web.id]
  user_data            = <<-EOF
#!/bin/bash
yum -y install httpd
echo "<html><head><title>Web Server</title></head><h1>Web X</h1><p>This is the web X server.</p></html>" > /var/www/html/index.html
chmod 644 /var/www/index.html
chown apache.apache /var/www/html/index.html
systemctl enable httpd.service
systemctl start httpd.service
    EOF

  tags = {
    Name = var.web_tier_name
    Description = "Web Server"
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