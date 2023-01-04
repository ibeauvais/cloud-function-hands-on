"""CFN to fill redis server with payload:
{"id": "groupID","secret": "randomID"}"""
import os
import logging
import redis
import google.cloud.logging
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

    if request.method not in ('GET', 'POST'):
        return Response("Forbidden method", status="403")

    if request.method == 'GET':
        if len(request.args) != 0 and 'id' in request.args:
            try:
                if REDIS_CLT.exists(request.args['id']):
                    secret = REDIS_CLT.get(name=request.args['id'])
                else:
                    return Response("Not Found", status="404")
            except Exception as err:
                logging.error("Redis get value error: %s", err)
            else:
                return Response(f"{secret.decode('utf-8')}\n", status="200")
        logging.error("Missing arguments in request")
    else:
        data: dict = request.get_json()
        if ('id', 'secret') in data or (len(data['id']), len(data['secret'])) != 0:
            try:
                REDIS_CLT.set(name=data['id'],
                              value=data['secret'])
            except Exception as err:
                logging.error("redis set value error: %s", err)
            else:
                return Response("Data inserted", status="200")
        logging.error("Missing key or value in payload")

    return Response("Request failed, please see cloud-function logs", status="400")
