"""Cloud Function HTTP to redis
"""
import logging
import os
import redis
import google.cloud.logging
from flask import Response

# Logging activation, needed in Gen2 Cloud Function
GCP_LOGGING_CLIENT = google.cloud.logging.Client()
GCP_LOGGING_CLIENT.get_default_handler()
GCP_LOGGING_CLIENT.setup_logging()

# env vars
REDIS_HOST = os.environ.get('REDIS_HOST')
REDIS_PORT = int(os.environ.get('REDIS_PORT'))
REDIS_PWD = os.environ.get('REDIS_PASSWORD')

# Redis client
REDIS_CLIENT = redis.Redis(host=REDIS_HOST,
                           port=REDIS_PORT,
                           password=REDIS_PWD)


def handle_request(request):
    """Handler method

    :param request: HTTP request
    :return: HTTP response
    """
    if request.method == 'GET':
        if len(request.args) != 0 and 'id' in request.args:
            try:
                if REDIS_CLIENT.exists(request.args['id']):
                    secret = REDIS_CLIENT.get(name=request.args['id'])
                    return Response(f"{secret.decode('utf-8')}\n", status="200")
                return Response("Not Found\n", status="404")
            except Exception as err:
                logging.error(f"{err}\n")
    return Response("Request failed\n", status="400")
