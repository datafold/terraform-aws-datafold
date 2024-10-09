import json
import logging
import os
import urllib3

from datadog_lambda.logger import initialize_logging


initialize_logging(__name__)
logger = logging.getLogger(__name__)
# logger.setLevel(logging.INFO)


def forward_to_private_system(data, private_endpoint, headers):
    """
    Forward the data to the private system endpoint.
    """
    http = urllib3.PoolManager(cert_reqs='CERT_NONE')  # Disable SSL certificate verification
    response = http.request(
        'POST', private_endpoint, body=data, headers=headers, assert_same_host=False
    )
    return response.status, response.data

def lambda_handler(event, context):
    private_system_endpoint = os.getenv('PRIVATE_SYSTEM_ENDPOINT')
    logger.info(f"Private system endpoint: {private_system_endpoint}")

    body = event.get('body', '')
    if not body:
        logger.error("No body found in the event")
        return {
            'statusCode': 400,
            'body': json.dumps('Bad Request: No payload found')
        }
    incoming_headers = event.get('headers', {})

    logger.info("Starting to forward the payload")
    status, response = forward_to_private_system(
        body, private_system_endpoint, incoming_headers
    )
    logger.info(f"Forwarding status: {status}")

    if status == 200:
        return {
            'statusCode': 200,
            'body': json.dumps('Webhook processed and forwarded')
        }
    else:
        logger.error(f"Error forwarding to private system ({status}): {response}")
        return {
            'statusCode': 500,
            'body': json.dumps('Internal Server Error: Failed to forward webhook')
        }