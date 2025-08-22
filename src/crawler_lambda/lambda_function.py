import boto3
import os

def lambda_handler(event, context):
    glue = boto3.client("glue")
    crawler_name = os.environ["CRAWLER_NAME"]

    glue.start_crawler(Name=crawler_name)
    return {"status": "started", "crawler": crawler_name}
