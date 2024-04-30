import json
import boto3

kinesis = boto3.client('kinesis')

def lambda_handler(event, context):
    try:
        data = json.loads(event['body'])
        response = kinesis.put_record(
            StreamName='my-data-stream',
            Data=json.dumps(data),
            PartitionKey='partitionkey'
        )
        return {
            'statusCode': 200,
            'body': json.dumps('Data published to Kinesis successfully')
        }
    except Exception as e:
        return {
            'statusCode': 500,
            'body': json.dumps(f'Error: {str(e)}')
        }
