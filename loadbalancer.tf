resource "aws_lb" "load_balancer" {
  name               = "lab-nlb"
  internal           = false
  load_balancer_type = "network"
  subnets            = [for subnet in aws_subnet.web_subnets: subnet.id]
}

resource "aws_lb_listener" "listener" {
  load_balancer_arn  = aws_lb.load_balancer.arn
  for_each           = var.forwarding_port
  port               = each.key
  protocol           = each.value

  default_action {
    target_group_arn = aws_lb_target_group.tg.arn
    type             = "forward"
  }
}

resource "aws_lb_target_group" "tg" {
  name        = "target-group"
  port        = "80"
  protocol    = "TCP"
  vpc_id      = aws_vpc.lab.id
  target_type = "instance"
}

resource "aws_lb_target_group_attachment" "web_tier_tg" {
  for_each         = aws_instance.web_tier
  target_group_arn = aws_lb_target_group.tg.arn
  target_id        = aws_instance.web_tier[each.key].id
  port             = 80
}


output "aws_lb_dns_name" {
  value = aws_lb.load_balancer.dns_name
}

output "aws_lb_id" {
  value = aws_lb.load_balancer.id
}

output "aws_lb_arn" {
  value = aws_lb.load_balancer.arn
}
