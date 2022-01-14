resource "aws_iam_role" "lambda_role" {
  name  = "lambda_role"
  tags  = var.tags
  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Principal": {
          "Service": "lambda.amazonaws.com"
        },
        "Action": "sts:AssumeRole"
      }
    ]
  }
EOF
}

resource "aws_iam_role_policy" "lambda_policy" {
  name   = "lambda_policy"
  role   = aws_iam_role.lambda_role.id
  policy = <<-EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
          "Effect": "Allow",
          "Action": [
            "logs:CreateLogGroup",
            "logs:CreateLogStream",
            "logs:PutLogEvents",
            "ec2:CreateNetworkInterface",
            "ec2:DescribeNetworkInterfaces",
            "ec2:DeleteNetworkInterface"
          ],
          "Resource": "*"
        },
        {
          "Effect": "Allow",
          "Action": [
            "secretsmanager:GetSecretValue",
            "secretsmanager:DescribeSecret",
            "secretsmanager:ListSecretVersionIds"
          ],
          "Resource": "${var.akamai_secrets_arn}*"
        }
    ]
}
  EOF
}

data "archive_file" "lambda_layer" {
  type        = "zip"
  source_dir  = "${path.module}/siteshield/siteshield.py"
  output_path = "siteshield.zip"
}

resource "aws_lambda_function" "lambda" {
  filename         = data.archive_file.lambda_zip.output_path
  source_code_hash = "${data.archive_file.lambda_zip.output_base64sha256}"
  function_name    = local.lambda_name
  description      = "Akamai Site Shield Lambda function."
  role             = aws_iam_role.lambda_role.arn
  timeout      	   = "300"
  handler          = "siteshield.handler"
  runtime          = "python3.8"
  tags             = var.tags 

  vpc_config {
    subnet_ids          = var.subnets
    security_group_ids  = [aws_security_group.sg_lambda.id]
  }
  environment {
    variables = {
      DEBUG = var.debug
      SECRET_ARN = var.akamai_secrets_arn
    }
  }
}
