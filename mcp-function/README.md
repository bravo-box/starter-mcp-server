# MCP Function

This directory contains a Python Azure Function that provides a default endpoint for MCP (Model Context Protocol) communication.

## Structure

- `function_app.py` - Main function app with MCP endpoint
- `host.json` - Azure Functions host configuration
- `requirements.txt` - Python dependencies

## Endpoint

### GET /api/mcp
Returns status information about the MCP endpoint.

**Response:**
```json
{
  "status": "success",
  "message": "MCP endpoint is running",
  "version": "1.0.0",
  "methods": ["GET", "POST"]
}
```

### POST /api/mcp
Processes MCP requests with custom actions.

**Request Body:**
```json
{
  "action": "your_action",
  "data": {
    "key": "value"
  }
}
```

**Response:**
```json
{
  "status": "success",
  "message": "Processed action: your_action",
  "action": "your_action",
  "data": {},
  "echo": {}
}
```

## Local Development

1. Install Azure Functions Core Tools
2. Install dependencies:
   ```bash
   pip install -r requirements.txt
   ```
3. Run locally:
   ```bash
   func start
   ```

## Deployment

Deploy using Azure CLI or the deployment scripts in the `../scripts` directory.
