import boto3
import json
import time

sqs_client = boto3.client("sqs", region_name="us-east-1")
dynamodb = boto3.resource('dynamodb')

def lambda_handler(event, context):
  try: 
    table = dynamodb.Table('comments')
    response = sqs_client.receive_message(
        QueueUrl="https://sqs.us-east-1.amazonaws.com/acc_id/comments",
        MaxNumberOfMessages=1,
        WaitTimeSeconds=10,
    )

    for message in response.get("Messages", []):
        message_body = message["Body"]
        data= json.loads(message_body)
        print(f"Receipt Handle: {message['ReceiptHandle']}")
        timer = round(time.time() * 1000)
        put_res = table.put_item(
            Item={
                'id': timer,
                'comment': data['comment'],
            }
            )
        delete_res = sqs_client.delete_message(
        QueueUrl="https://sqs.us-east-1.amazonaws.com/acc_id/comments",
        ReceiptHandle=message['ReceiptHandle'],
        )
  except Exception as e:
    print('something went wrong!')
    print(e)