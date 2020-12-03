# Open to world
variable "cidr_block_world" {
    default = "0.0.0.0/0"
}

variable "web_subnets" {
  type = map
  default = {
    us-west-2a = "10.0.20.0/24"
    us-west-2b = "10.0.21.0/24"
  }
}
variable "web_instance_type" {
  type = string
  default = "t3.nano"
}

variable "jumpbox_instance_type" {
  type = string
  default = "t3.small"
}

variable "web_tier_name" {
  type = string
  default = "internal-web-server-tier"
}
variable "forwarding_port" {
  default = {
    "80"  = "TCP"
  }
}

