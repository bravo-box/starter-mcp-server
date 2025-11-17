# Chat App

This directory contains a C# chat application that integrates with Azure OpenAI in Azure Government.

## Features

- REST API for chat interactions with Azure OpenAI
- Configured for Azure Government cloud
- Dockerized for easy deployment
- Health check endpoint
- Swagger/OpenAPI documentation

## Configuration

Update `appsettings.json` or use environment variables:

```json
{
  "AzureOpenAI": {
    "Endpoint": "https://your-aoai.openai.azure.us/",
    "ApiKey": "your-api-key",
    "DeploymentName": "your-deployment-name",
    "ApiVersion": "2024-02-15-preview"
  }
}
```

### Environment Variables

- `AzureOpenAI__Endpoint` - Azure OpenAI endpoint URL (Azure Government)
- `AzureOpenAI__ApiKey` - Azure OpenAI API key
- `AzureOpenAI__DeploymentName` - Deployment/model name
- `AzureOpenAI__ApiVersion` - API version

## API Endpoints

### GET /health
Health check endpoint

**Response:**
```json
{
  "status": "healthy",
  "timestamp": "2024-01-01T00:00:00Z"
}
```

### POST /api/chat
Send a chat message

**Request:**
```json
{
  "message": "Hello, how are you?"
}
```

**Response:**
```json
{
  "response": "I'm doing well, thank you for asking!",
  "timestamp": "2024-01-01T00:00:00Z"
}
```

## Local Development

1. Install .NET 8.0 SDK
2. Update `appsettings.json` with your Azure OpenAI credentials
3. Run:
   ```bash
   dotnet run
   ```
4. Access Swagger UI at `https://localhost:5001/swagger`

## Docker Build

Build the container:
```bash
docker build -t chat-app .
```

Run the container:
```bash
docker run -p 8080:8080 \
  -e AzureOpenAI__Endpoint="https://your-aoai.openai.azure.us/" \
  -e AzureOpenAI__ApiKey="your-key" \
  -e AzureOpenAI__DeploymentName="your-deployment" \
  chat-app
```

## Deployment

Deploy using the deployment scripts in the `../scripts` directory or deploy the container to Azure Web Apps.
