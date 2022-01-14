variable "tags" {
  description = "Optional : A map of tags to assign to the resource."
  type        = map(string)
  default     = {}
}

variable "vpc_id" {
  description = "Required : The VPC ID to deploy this to."
  type = string
}

variable "subnets" {
  description = "Required : The list of subnet IDs To Deploy to."
  type = list(string)
}

variable "siteshield_name" {
  description = "Optional : Used to build names of avrious components. Default is akamai_siteshield"
  type = string
  default = "akamai-siteshield"
}

variable "sg_name_postfix" {
  description = "Optional : The postfix name of the AWS Security Group. Default is -sg"
  type = string
  default = "-sg"
}

variable "lambda_sg_name_prefix" {
  description = "Optional : The prefix for the Lmabda AWS Security Group. Default is lambda_"
  type = string
  default = "lambda-"
}

variable "lb_sg_name_prefix" {
  description = "Optional : The prefix for the Load Balancer AWS Security Group. Default is alb_"
  type = string
  default = "alb-"
}

variable "sg_src_cidr_blocks" {
  description = "Optional : List of the networks to allow to the Load Balancer. Defaults to RFC1918"
  type = list(string)
  default = ["10.0.0.0/8", "192.168.0.0/16", "172.16.0.0/12"]
}


variable "lb_name_prefix" {
  description = "Optional : The prefix for the Load Balancer AWS Security Group. Default is blank"
  type = string
  default = ""
}

variable "lb_name_postfix" {
  description = "Optional : The prefix for the Load Balancer AWS Security Group. Default is _alb"
  type = string
  default = "_alb"
}

variable "debug" {
  description = "Optional : Debug the Lambda function. Defaults is false."
  type = bool
  default = false
}