output "lb_dns_name" {
  description = "The DNS name of the Webhook LB"
  value       = "http://${aws_lb.webhook_alb.dns_name}"
}

output "sg_lambda" {
  description = "The Lambda Security Group"
  value       = aws_security_group.sg_lambda
}

output "sg_lb" {
  description = "The Load Balancer Security Group"
  value       = aws_security_group.sg_lb
}

output "aws_lb" {
  description = "The AWS Load Balancer webhook_alb"
  value       = aws_lb.webhook_alb
}