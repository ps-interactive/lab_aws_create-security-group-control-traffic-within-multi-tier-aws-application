# show the vpc
aws ec2 describe-vpcs --output table
# show the subnets
aws ec2 describe-subnets --output table
# show the ec2 instances
aws ec2 describe-instances --output table
# show security groups
aws ec2 describe-security-groups --output table