"""Pub/Sub Cloud Function
"""
import base64


def handle_message(event, context):
    """Handler method

    :param event: Cloud Function event
    :param context: Cloud Function context
    """
    pubsub_message = base64.b64decode(event['data']).decode('utf-8')
    print(pubsub_message)
