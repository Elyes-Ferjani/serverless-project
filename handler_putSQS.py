import boto3
import json
sqs_client = boto3.client("sqs", region_name="us-east-1")


def lambda_handler(event, context):
    data = json.loads(event["body"])["comment"]
    message = {"comment": data}
    response = sqs_client.send_message(
        QueueUrl="https://sqs.us-east-1.amazonaws.com/acc_id/comments",
        MessageBody=json.dumps(message)
    )
    print(response)
    return
