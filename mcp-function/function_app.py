import azure.functions as func
import json
import logging

app = func.FunctionApp(http_auth_level=func.AuthLevel.FUNCTION)

@app.route(route="mcp", methods=["GET", "POST"])
def mcp_endpoint(req: func.HttpRequest) -> func.HttpResponse:
    """
    Default MCP endpoint for the Azure Function.
    
    This endpoint can be called by MCP clients to interact with the function.
    It accepts both GET and POST requests.
    """
    logging.info('MCP endpoint triggered.')
    
    try:
        # Handle GET requests
        if req.method == "GET":
            return func.HttpResponse(
                json.dumps({
                    "status": "success",
                    "message": "MCP endpoint is running",
                    "version": "1.0.0",
                    "methods": ["GET", "POST"]
                }),
                mimetype="application/json",
                status_code=200
            )
        
        # Handle POST requests
        elif req.method == "POST":
            try:
                req_body = req.get_json()
            except ValueError:
                return func.HttpResponse(
                    json.dumps({
                        "status": "error",
                        "message": "Invalid JSON in request body"
                    }),
                    mimetype="application/json",
                    status_code=400
                )
            
            # Extract parameters from request
            action = req_body.get('action', 'unknown')
            data = req_body.get('data', {})
            
            # Process the request
            logging.info(f'Processing action: {action}')
            
            # Return response
            return func.HttpResponse(
                json.dumps({
                    "status": "success",
                    "message": f"Processed action: {action}",
                    "action": action,
                    "data": data,
                    "echo": req_body
                }),
                mimetype="application/json",
                status_code=200
            )
            
    except Exception as e:
        logging.error(f'Error processing request: {str(e)}')
        return func.HttpResponse(
            json.dumps({
                "status": "error",
                "message": str(e)
            }),
            mimetype="application/json",
            status_code=500
        )
