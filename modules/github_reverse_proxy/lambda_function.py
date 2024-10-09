import json
import hashlib
import hmac
import os
import urllib3

def verify_github_signature(headers, body, secret):
    """
    Verifies the GitHub webhook signature using the provided secret.
    """
    signature = headers.get('X-Hub-Signature-256')

    if not signature:
        print("No signature found in headers.")
        return False

    # Create the HMAC digest
    hmac_gen = hmac.new(key=secret.encode(), msg=body, digestmod=hashlib.sha256)
    expected_signature = f'sha256={hmac_gen.hexdigest()}'

    return hmac.compare_digest(signature, expected_signature)

def forward_to_private_system(data, private_endpoint):
    """
    Forward the data to the private system endpoint.
    """
    http = urllib3.PoolManager()
    headers = {'Content-Type': 'application/json'}

    response = http.request('POST', private_endpoint, body=json.dumps(data), headers=headers)

    return response.status, response.data

def lambda_handler(event, context):
    github_secret = os.getenv('GITHUB_SECRET')
    private_system_endpoint = os.getenv('PRIVATE_SYSTEM_ENDPOINT')

    headers = event.get('headers', {})
    body = event.get('body', '')

    # Verify GitHub signature
    if not verify_github_signature(headers, body.encode('utf-8'), github_secret):
        print("Signature verification failed.")
        return {
            'statusCode': 403,
            'body': json.dumps('Forbidden: Signature verification failed')
        }

    # Parse the body as JSON
    try:
        payload = json.loads(body)
    except json.JSONDecodeError as e:
        print(f"JSON parsing error: {e}")
        return {
            'statusCode': 400,
            'body': json.dumps('Bad Request: Invalid JSON payload')
        }

    # Forward the payload to the private system
    status, response = forward_to_private_system(payload, private_system_endpoint)

    if status == 200:
        return {
            'statusCode': 200,
            'body': json.dumps('Webhook processed and forwarded')
        }
    else:
        print(f"Error forwarding to private system: {response}")
        return {
            'statusCode': 500,
            'body': json.dumps('Internal Server Error: Failed to forward webhook')
        }