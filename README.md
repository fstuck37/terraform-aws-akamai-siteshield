AWS Lambda Akamai Siteshield Public IPs
=============
This module deploys an ALB, Lambda, etc. to connect to Akamai Site shield API and provides a list of public IPs

Example
------------
```
module "siteshield" {
  source             = "git::https://github.com/fstuck37/terraform-aws-akamai-siteshield.git"
  vpc_id             = "vpc-123456abc"
  subnets            = ["subnet-1234567890abcdef12","subnet-123456789012abcdef","subnet-abcdef123456789012"]
  akamai_secrets_arn = "arn:aws:secretsmanager:us-east-1:123456789012:secret:akamai/siteshield"
  tags               = var.tags
}

output "siteshield" {
  value = module.siteshield.lb_dns_name
}

```

Argument Reference
------------
   * **vpc_id** - Required : The VPC ID to deploy this to.
   * **subnets** - Required : The list of subnet IDs To Deploy to.
   * **akamai_secrets_arn** - Required : The ARN to the Secrets manager entry for Akamia information.

   * **tags** - Optional : A map of tags to assign to the resource.
   * **siteshield_name** - Optional : Used to build names of avrious components. Default is akamai_siteshield
   * **sg_name_postfix** - Optional : The postfix name of the AWS Security Group. Default is -sg
   * **lambda_sg_name_prefix** - Optional : The prefix for the Lmabda AWS Security Group. Default is lambda_
   * **lb_sg_name_prefix** - Optional : The prefix for the Load Balancer AWS Security Group. Default is alb_
   * **sg_src_cidr_blocks** - Optional : List of the networks to allow to the Load Balancer. Defaults to RFC1918
   * **lb_name_prefix** - Optional : The prefix for the Load Balancer AWS Security Group. Default is blank
   * **lb_name_postfix** - Optional : The prefix for the Load Balancer AWS Security Group. Default is _alb
   * **force_cache** - Optional : Force the Lambda to load from cahce. Defaults to False
   * **debug** - Optional : Debug the Lambda function. Defaults is false.

Output Reference
------------
   * **lb_dns_name** - The DNS name of the Webhook LB
   * **sg_lambda** - The Lambda Security Group
   * **sg_lb** - The Load Balancer Security Group
   * **aws_lb** - The AWS Load Balancer webhook_alb
   * **aws_lambda_function** - The AWS Lambda Function