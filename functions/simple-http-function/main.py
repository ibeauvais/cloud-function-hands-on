def handle_request(request):
    if request.args and 'name' in request.args:
        return f"Hello {request.args.get('name')}"
    else:
        return "Hello world"

