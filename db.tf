# variables, outside dependencies
# variable "db_subnet_id" {
#   type = string
#   default = "aws_subnet.internal_db_subnet.id"
# }
variable "ami" {
  type = string
  default = "data.aws_ami.amazon_linux_v2.id"
}

resource "aws_instance" "db_server" {
  ami                  = var.ami
  subnet_id            = aws_subnet.internal_db_subnet.id
  instance_type        = "t3.micro"
  # iam_instance_profile = aws_iam_instance_profile.bastion_profile.name
  # security_groups      = [aws_security_group.db.id]
  user_data            = <<-EOF
    #!/bin/bash
    curl http://repo.mysql.com/yum/mysql-5.5-community/el/7/x86_64/mysql-community-release-el7-5.noarch.rpm > /tmp/mysql-community-release-el7-5.noarch.rpm
    yum update -y
    yum install -y /tmp/mysql-community-release-el7-5.noarch.rpm
    yum install -y mysql-community-server git
    systemctl enable mysqld
    systemctl start mysqld
    mysqladmin -u root password '****'
    mysql -u root -p**** -e "CREATE DATABASE employees"
    wget https://raw.githubusercontent.com/datacharmer/test_db/master/employees.sql
    mysql -u root -p**** employees < /employees.sql
    mysql -u root -p**** < /lab_aws_implement-data-ingestion-solution-using-aws-database-migration-aws/user_perm.sql
    EOF
  tags = {
    Name    = "Database Server"
    # Env     = var.environment
    # Project = var.project_name
  }
} 

# # db subnet group
# resource "aws_db_subnet_group" "db_subnet_group" {
#   name       = "db-subnet-group"
#     # put in db subnet
#   subnet_ids = [aws_subnet.internal_db_subnet.id]

#   tags = {
#     Name = "My DB subnet group"
#   }
# }


# # db instance
# resource "aws_db_instance" "lab_rds" {
#   identifier          = "lab-db-instance"
#   instance_class      = "db.t2.micro"
#   allocated_storage   = 10
#   engine              = "mysql"
#   engine_version      = "5.7"
#   name                = "labdb"
#   username            = "labuser"
#   password            = "LabPass20"
#   skip_final_snapshot = true

#   db_subnet_group_name = "db_subnet_group"
# }