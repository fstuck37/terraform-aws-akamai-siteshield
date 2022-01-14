locals {
  lambda_sg_name = "${var.lambda_sg_name_prefix}${var.siteshield_name}${var.sg_name_postfix}"
  lb_sg_name     = "${var.lb_sg_name_prefix}${var.siteshield_name}${var.sg_name_postfix}"
  lb_name        = "${var.lb_name_prefix}${var.siteshield_name}${var.lb_name_postfix}"
}



