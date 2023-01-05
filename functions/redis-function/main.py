"""Cloud Function HTTP to redis
"""
import redis
from flask import Response


REDIS_CLIENT = redis.Redis(host="my_redis_server",
                           port=6379,
                           password="my_redis_password")


def handle_request(request):
    """Handler method

    :param request: HTTP request
    :return:
    """
    if request.method == 'GET':
        if len(request.args) != 0 and 'id' in request.args:
            if REDIS_CLIENT.exists(request.args['id']):
                secret = REDIS_CLIENT.get(name=request.args['id'])
                return Response(f"{secret.decode('utf-8')}\n", status="200")
        return Response("Not Found", status="404")
    return Response("Request failed", status="400")

