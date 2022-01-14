resource "aws_lb" "webhook_alb" {
  name               = local.lb_name
  internal           = true
  load_balancer_type = "application"
  security_groups    = [aws_security_group.sg_lb.id]
  subnets            = var.subnets
  tags               = var.tags 
}

resource "aws_lb_listener" "webhook_alb_listener" {
  load_balancer_arn = aws_lb.webhook_alb.arn
  port              = "80"
  protocol          = "HTTP"
  
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.webhook_tg.arn
  }
}

resource "aws_lambda_alias" "webhook" {
  name             = "lambda_alias"
  description      = "Lambda Alias"
  function_name    = aws_lambda_function.lambda.arn
  function_version = aws_lambda_function.lambda.version
}

resource "aws_lb_target_group" "webhook_tg" {
  name        = "webhook-tg"
  target_type = "lambda"
  tags        = var.tags
}

resource "aws_lambda_permission" "webhook" {
  statement_id  = "AllowExecutionFromALB"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda.function_name
  principal     = "elasticloadbalancing.amazonaws.com"
  qualifier     = aws_lambda_alias.webhook.name
  source_arn    = aws_lb_target_group.webhook_tg.arn
}

resource "aws_lb_target_group_attachment" "webhook" {
  target_group_arn = aws_lb_target_group.webhook_tg.arn
  target_id        = aws_lambda_alias.webhook.arn
  depends_on = [ aws_lambda_permission.webhook ]
}

resource "aws_lb_listener_rule" "webhook" {
  listener_arn = aws_lb_listener.webhook_alb_listener.arn
  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.webhook_tg.arn
  }
    condition {
    path_pattern {
      values = ["/*"]
    }
  }
}
