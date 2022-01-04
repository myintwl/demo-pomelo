import json

def lambda_handler(event, context):
    for record in event['Records']:
        payload = json.loads(record['body'])

        value1 = payload['value1']
        value2 = payload['value2']

        value_sum = value1 + value2
        print("the sum is %s" % value_sum)
        
    return "OK"