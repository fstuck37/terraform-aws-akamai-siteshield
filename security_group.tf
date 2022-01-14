resource "aws_security_group" "sg_lb" {
  name        = local.lb_sg_name
  description = "Allows connections to Load Balancer"
  vpc_id      = var.vpc_id
  tags        = var.tags 
}

resource "aws_security_group_rule" "sg_lb_ingress_rule" {
  security_group_id        = aws_security_group.sg_lb.id
  description              = "Only allow connections from Bitbucket VPC."
  type                     = "ingress"
  from_port                = "80"
  to_port                  = "80"
  protocol                 = "tcp"
  cidr_blocks              = var.sg_src_cidr_blocks
}

resource "aws_security_group_rule" "sg_lb_https_ingress_rule" {
  security_group_id        = aws_security_group.sg_lb.id
  description              = "Only allow connections from Bitbucket VPC."
  type                     = "ingress"
  from_port                = "443"
  to_port                  = "443"
  protocol                 = "tcp"
  cidr_blocks              = var.sg_src_cidr_blocks
}

resource "aws_security_group" "sg_lambda" {
  name        = local.lambda_sg_name
  description = "Allow connections from Load Balancer while limiting connections from other resources."
  vpc_id      = var.vpc_id
  tags        = var.tags 
}

resource "aws_security_group_rule" "sg_lambda_ingress_rule" {
  security_group_id        = aws_security_group.sg_lambda.id
  description              = "Only allow connections from ALB SG."
  type                     = "ingress"
  from_port                = "80"
  to_port                  = "80"
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.sg_lb.id
}

resource "aws_security_group_rule" "sg_lambda_egress_rule" {
  security_group_id = aws_security_group.sg_lambda.id
  description       = "Allows lambda to establish connections to all resources"
  type              = "egress"
  from_port         = "0"
  to_port           = "0"
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
}
