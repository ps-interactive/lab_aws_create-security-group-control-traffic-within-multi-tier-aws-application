# variables, outside dependencies
# variable "web_subnet_id" {
#   type = string
#   default = "aws_subnet.internal_web_subnet.id"
# }

# ami for amazon hvm version 2 web server
# Get latest Amazon Linux 2 AMI


resource "aws_instance" "web_server" {
  ami                  = data.aws_ami.amazon_linux_2.id
  subnet_id            = aws_subnet.internal_web_subnet.id
  instance_type        = "t2.nano"
  # iam_instance_profile = aws_iam_instance_profile.bastion_profile.name
  # security_groups      = [aws_security_group.web.id]
  user_data            = <<-EOF
      #!/bin/bash
      yum update -y
      amazon-linux-extras install -y php7.2
      yum install -y httpd
      systemctl start httpd
      systemctl enable httpd
      yum install -y git
      cd /var/www/
      git clone https://github.com/ps-interactive/lab_aws_create-application-load-balancer-with-http-listener
      cp -R /var/www/lab_aws_create-application-load-balancer-with-http-listener/carved_rock_site/* /var/www/html/
    EOF
  tags = {
    Name    = "Web Server"
  }
} 

# # web subnet group
# resource "aws_web_subnet_group" "web_subnet_group" {
#   name       = "web-subnet-group"
#     # put in web subnet
#   subnet_ids = [aws_subnet.internal_web_subnet.id]

#   tags = {
#     Name = "My web subnet group"
#   }
# }


# # web instance
# resource "aws_web_instance" "lab_rds" {
#   identifier          = "lab-web-instance"
#   instance_class      = "web.t2.micro"
#   allocated_storage   = 10
#   engine              = "mysql"
#   engine_version      = "5.7"
#   name                = "labweb"
#   username            = "labuser"
#   password            = "LabPass20"
#   skip_final_snapshot = true

#   web_subnet_group_name = "web_subnet_group"
# }