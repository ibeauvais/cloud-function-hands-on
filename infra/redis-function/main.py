"""CFN to fill redis server with payload:
{"id": "groupID","secret": "randomID"}"""
import os
import redis
import google.cloud.logging
import logging
from flask import Response

# Init cloud logging
GCP_LOGGING_CLT = google.cloud.logging.Client()
REDIS_HOST = os.environ.get('REDISHOST', 'localhost')
REDIS_PORT = int(os.environ.get('REDISPORT', 6379))
REDIS_AUTH = os.environ.get('REDIS_PASSWORD', "")
REDIS_CLT = redis.Redis(host=REDIS_HOST,
                        port=REDIS_PORT,
                        password=REDIS_AUTH)


def handle_request(request):
    """GCP function
    return 200 and data from get
    return 200 from post
    return 400 if exception

    :param request: HTTP request
    :return: status code 200 and data if get method
    :rtype: flask.Response
    """
    GCP_LOGGING_CLT.get_default_handler()
    GCP_LOGGING_CLT.setup_logging()
    if request.method == 'GET':
        if len(request.args) != 0 and 'id' in request.args:
            secret = ""
            try:
                if REDIS_CLT.exists(request.args['id']):
                    secret = REDIS_CLT.get(name=request.args['id'])
            except redis.exceptions as err:
                logging.error("redis get value error: %s", err)
            else:
                if len(secret) != 0:
                    return Response(secret, status="200")
        return Response("Request failed", status="400")

    if request.method == 'POST':
        payload_json: dict = request.get_json()
        if 'id' not in payload_json or 'secret' not in payload_json:
            logging.error("missing 'id' or 'secret' key in payload")
            return Response(status="400")
        if len(payload_json['id']) == 0 or len(payload_json['secret']) == 0:
            logging.error("'id' or 'secret' has no value in payload")
            return Response(status="400")
        try:
            REDIS_CLT.set(name=payload_json['id'],
                          value=payload_json['secret'])
        except redis.exceptions as err:
            logging.error("redis set value error: %s", err)
            return Response("Request failed", status="400")
        return Response("Data inserted", status="200")
