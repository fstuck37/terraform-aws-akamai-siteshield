AWS Lambda Akamai Site Shield Public IPs
=============
This module deploys an ALB, Lambda, etc. to connect to Akamai Site shield API and provides a list of public IPs.
The module also creates an S3 Bucket that will be used to cache the data from the last successful load from Akamai.
If there is ever an error connecting to Akamai it will return the file form the cache.

Example
------------
```
module "Site Shield" {
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
   * **akamai_secrets_arn** - Required : The ARN to the Secrets manager entry for Akamai security information.
     The Secrets Manager entry must contain the following settings:
     - host
     - client_secret
     - access_token
     - client_token

   * **tags** - Optional : A map of tags to assign to the resource.
   * **siteshield_name** - Optional : Used to build names of various components. Default is akamai_siteshield
   * **sg_name_postfix** - Optional : The postfix name of the AWS Security Group. Default is -sg
   * **lambda_sg_name_prefix** - Optional : The prefix for the Lambda AWS Security Group. Default is lambda_
   * **lb_sg_name_prefix** - Optional : The prefix for the Load Balancer AWS Security Group. Default is alb_
   * **sg_src_cidr_blocks** - Optional : List of the networks to allow to the Load Balancer. Defaults to RFC1918
   * **lb_name_prefix** - Optional : The prefix for the Load Balancer AWS Security Group. Default is blank
   * **lb_name_postfix** - Optional : The prefix for the Load Balancer AWS Security Group. Default is _alb
   * **force_cache** - Optional : Force the Lambda to load from cache. Defaults to False
   * **debug** - Optional : Debug the Lambda function. Defaults is false.

Output Reference
------------
   * **lb_dns_name** - The DNS name of the Akamai Load Balancer
   * **sg_lambda** - The Lambda Security Group
   * **sg_lb** - The Load Balancer Security Group
   * **aws_lb** - The AWS Load Balancer webhook_alb
   * **aws_lambda_function** - The AWS Lambda Function
   * **s3_bucket** - The ARN of the Cache S3 Bucket