import boto3
dynamodb = boto3.resource('dynamodb', region_name="us-east-1")

def lambda_handler(event, context):

    table = dynamodb.Table('comments')

    response = table.scan()
    data = response['Items']

    while 'LastEvaluatedKey' in response:
        response = table.scan(ExclusiveStartKey=response['LastEvaluatedKey'])
        data.extend(response['Items'])
    return data
