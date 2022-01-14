import os
import boto3
import logging
import urllib.request
import base64
from botocore.exceptions import ClientError


logger = logging.getLogger()
logger.setLevel(logging.INFO)
debug = os.getenv("DEBUG")
secret_arn = os.getenv("SECRET_ARN")
secret_name = secret_arn.split(":")[-1]

def handler(event, context):
    print("EVENT", event)
    if event['httpMethod'] == "GET":
        path = event["path"][1:] 
        logger.info(f"Context Path Received: {path}")
        contents = boto3.client("secretsmanager").get_secret_value("akamai/siteshield")["SecretString"]
       
        response = {
            "statusCode": 200,
            "statusDescription": "200 OK",
            "isBase64Encoded": False,
            "body" : contents,
            "headers": {
            "Content-Type": "text; charset=utf-8"
            }
        }
        return response




