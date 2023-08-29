output "lb_endpoint" {
  value = "http://${aws_lb.scaling-lb.dns_name}"
}

output "asg_name" {
  value = aws_autoscaling_group.scaling-asg.name
}
