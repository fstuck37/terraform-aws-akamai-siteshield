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

data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = "${path.module}/siteshield/"
  output_path = "siteshield.zip"
}

data "archive_file" "lambda_layer" {
    type        = "zip"
    source_dir  = "${path.module}/layer/"
    output_path = "lambda_layer.zip"
}

resource "aws_lambda_layer_version" "lambda_layer" {
  filename            = "lambda_layer.zip"
  description         = "Akamai Lambda Layer"
  layer_name          = "${local.lambda_name}-lambda-layer"
  source_code_hash    = "${data.archive_file.lambda_layer.output_base64sha256}"
  compatible_runtimes = ["python3.8"]
}

resource "aws_lambda_function" "lambda" {
  filename         = data.archive_file.lambda_zip.output_path
  source_code_hash = "${data.archive_file.lambda_zip.output_base64sha256}"
  layers           = [aws_lambda_layer_version.lambda_layer.arn]
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

// ----------------------------------------------------------------------------
data "archive_file" "lambda_layer" {
    type        = "zip"
    source_dir  = "${path.module}/../src/layers/api"
    output_path = "lambda_layer.zip"
}

resource "aws_lambda_layer_version" "lambda_layer" {
  filename            = "lambda_layer.zip"
  description         = "${var.name} lambda layer ${var.env}"
  layer_name          = "${var.name}-lambda-layer-${var.env}"
  source_code_hash    = "${data.archive_file.lambda_layer.output_base64sha256}"
  compatible_runtimes = ["python3.8"]
}


