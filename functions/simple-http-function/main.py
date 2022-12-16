def handle_request(request):
    if request.args and 'who' in request.args:
        return f"Hello {request.args.get('who')}"
    else:
        return "Hello world"

