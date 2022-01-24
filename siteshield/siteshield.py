import os
import boto3
import logging
import urllib.request
import base64
from botocore.exceptions import ClientError
import json
import requests
from urllib.parse import urljoin
from akamai.edgegrid import EdgeGridAuth, EdgeRc
import datetime

logger = logging.getLogger()
logger.setLevel(logging.INFO)
debug = str(os.getenv("DEBUG")) == "True"
secret_arn = os.getenv("SECRET_ARN")
bucket_name = os.getenv("BUCKET")
force_cache = str(os.getenv("FORCE_CACHE")) == "True"
secret_name = secret_arn.split(":")[-1]

def handler(event, context):
  if debug: logger.info('siteshield.py : Handler : start with debugging')
  if event['httpMethod'] == "GET":
    if debug: logger.info('siteshield.py : Handler : GET ')
    path = event["path"][1:] 
    if debug: logger.info(f"siteshield.py : Handler : Context Path Received: {path}")
    if debug: logger.info(f"siteshield.py : Handler : secret_arn {secret_arn}")
    if debug: logger.info(f"siteshield.py : Handler : secret_name {secret_name}")
    if debug: logger.info(f"siteshield.py : Handler : force_cache {force_cache}")
    
    if force_cache :
      if debug: logger.info(f"siteshield.py : Handler : force_cache {force_cache}")
      contents = s3_get()
    else :
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
      try:
        contents = akamai(get_secret_json)
      except:
        contents = s3_get()
    
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
  else :
    logger.info(f"siteshield.py : Handler : Error Not HTTP GET Method")
    return "Error"

def akamai(get_secret_json):
  all_ips = list()
  if debug: logger.info('siteshield.py : get_secret_json : start')
  baseurl = get_secret_json["host"]
  client_secret = get_secret_json["client_secret"]
  access_token = get_secret_json["access_token"]
  client_token = get_secret_json["client_token"]
  s = requests.Session()
  s.auth = EdgeGridAuth(
    client_token=client_token,
    client_secret=client_secret,
    access_token=access_token
  )
  result = s.get(f"https://{baseurl}/siteshield/v1/maps").json()
  for i in result['siteShieldMaps']:
    all_ips.extend(i.get('currentCidrs',[]))
    all_ips.extend(i.get('proposedCidrs',[]))
  all_ips=list(set(all_ips))
  output = str("\n".join(all_ips))
  s3_put(output)
  return output

def s3_put(data):
  if debug: logger.info('siteshield.py : s3_put : Bucket = ' + bucket_name )
  if debug: logger.info('siteshield.py : s3_put : Data = ' + data )
  d = datetime.datetime.now().strftime("%I:%M%p on %B %d, %Y")
  byte_data = bytes("Cached " + d +  "\n" + data , 'utf-8')
  s3 = boto3.resource("s3")
  object = s3.Object(bucket_name.split(":")[-1], 'cached.txt')
  result = object.put(Body=byte_data)

def s3_get():
  if debug: logger.info('siteshield.py : s3_get : Bucket = ' + bucket_name )
  s3 = boto3.resource("s3")
  object = s3.Object(bucket_name.split(":")[-1], 'cached.txt')
  result = object.get()['Body'].read().decode('utf-8')
  return result
