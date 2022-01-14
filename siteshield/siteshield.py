import os
import boto3
import logging
import urllib.request

logger = logging.getLogger()
logger.setLevel(logging.INFO)
debug = os.getenv("DEBUG")

def handler(event, context):
    print("EVENT", event)
    if event['httpMethod'] == "GET":
        path = event["path"][1:] 
        logger.info(f"Context Path Received: {path}")
        contents = "This is a test"
        
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