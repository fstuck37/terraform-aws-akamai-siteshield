import os
import boto3
import logging
import urllib.request
import base64
from botocore.exceptions import ClientError
import json
from botocore.vendored import requests
from urllib.parse import urljoin
from akamai.edgegrid import EdgeGridAuth, EdgeRc

logger = logging.getLogger()
logger.setLevel(logging.INFO)
debug = bool(os.getenv("DEBUG"))
secret_arn = os.getenv("SECRET_ARN")
secret_name = secret_arn.split(":")[-1]

def handler(event, context):
  if debug: logger.info('siteshield.py : Handler : start')
  if event['httpMethod'] == "GET":
    if debug: logger.info('siteshield.py : Handler : GET ')
    path = event["path"][1:] 
    if debug: logger.info(f"siteshield.py : Handler : Context Path Received: {path}")
    if debug: logger.info(f"siteshield.py : Handler : secret_arn {secret_arn}")
    if debug: logger.info(f"siteshield.py : Handler : secret_name {secret_name}")
    
    try:
      get_secret_value_response = boto3.client("secretsmanager").get_secret_value(SecretId=secret_name)
      get_secret_json = json.loads(get_secret_value_response["SecretString"])
      client_secret = get_secret_json["client_secret"]
      host = get_secret_json["host"]
      access_token = get_secret_json["access_token"]
      client_token = get_secret_json["client_token"]
    except ClientError as e:
      logger.info("ClientError : siteshield.py : Handler : secretsmanager " + e.response['Error']['Code'])
    except KeyError as e:
      logger.info("KeyError : Secret requires client_secret, access_token, client_token, and host")
    
    contents = "this is only a test " + akamai(get_secret_json)
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

def akamai(get_secret_json):
  if debug: logger.info('siteshield.py : get_secret_json : start')
  return "TEST"
