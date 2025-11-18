# MCP Starter Server

A comprehensive starter repository demonstrating the Model Context Protocol (MCP) with Azure services. This repository provides a complete solution for deploying an MCP-enabled Azure Function, a chat application integrated with Azure OpenAI in Azure Government, and the necessary infrastructure.

## 🏗️ Architecture

This repository contains:

- **mcp-function** - Python Azure Function providing an MCP endpoint
- **chat-app** - C# chat application with Azure OpenAI integration (containerized)
- **infra** - Bicep templates for Azure infrastructure deployment
- **scripts** - Automated deployment scripts

## 📁 Repository Structure

```
starter-mcp-server/
├── mcp-function/          # Python Azure Function
│   ├── function_app.py    # MCP endpoint implementation
│   ├── host.json          # Function host configuration
│   ├── requirements.txt   # Python dependencies
│   └── README.md          # Function documentation
├── chat-app/              # C# Chat Application
│   ├── ChatApp.csproj     # .NET project file
│   ├── Program.cs         # Application entry point
│   ├── ChatService.cs     # Azure OpenAI service
│   ├── Models.cs          # Request/Response models
│   ├── Dockerfile         # Container definition
│   ├── appsettings.json   # Application configuration
│   └── README.md          # App documentation
├── infra/                 # Infrastructure as Code
│   ├── main.bicep         # Main orchestration template
│   ├── main.parameters.json # Default parameters
│   ├── modules/           # Bicep modules
│   │   ├── function-app.bicep
│   │   ├── openai.bicep
│   │   └── web-app.bicep
│   └── README.md          # Infrastructure documentation
├── scripts/               # Deployment Scripts
│   ├── deploy-infrastructure.sh
│   ├── deploy-function.sh
│   ├── deploy-chat-app.sh
│   └── README.md          # Scripts documentation
├── .gitignore
├── LICENSE
└── README.md
```

## 🚀 Quick Start

### Prerequisites

- [Azure CLI](https://docs.microsoft.com/cli/azure/install-azure-cli) installed
- [Azure Functions Core Tools](https://docs.microsoft.com/azure/azure-functions/functions-run-local) v4
- [Docker](https://docs.docker.com/get-docker/) installed and running
- [.NET 8.0 SDK](https://dotnet.microsoft.com/download) (for local development)
- [Python 3.11](https://www.python.org/downloads/) (for local development)
- Access to Azure Government subscription (or modify for commercial Azure)
- `jq` command-line JSON processor

### Azure Government Setup

```bash
# Set Azure CLI to use Azure Government
az cloud set --name AzureUSGovernment

# Login to Azure Government
az login

# Verify you're on the right cloud
az cloud show
```

### Deployment

Deploy everything in three simple steps:

```bash
cd scripts

# 1. Deploy infrastructure (10-15 minutes)
./deploy-infrastructure.sh

# 2. Deploy the Azure Function
./deploy-function.sh

# 3. Build and deploy the Chat App container
./deploy-chat-app.sh
```

## 🔧 Local Development

### MCP Function (Python)

```bash
cd mcp-function

# Create virtual environment
python3 -m venv .venv
source .venv/bin/activate

# Install dependencies
pip install -r requirements.txt

# Run locally
func start
```

Test the endpoint:
```bash
# GET request
curl http://localhost:7071/api/mcp

# POST request
curl -X POST http://localhost:7071/api/mcp \
  -H "Content-Type: application/json" \
  -d '{"action": "test", "data": {"key": "value"}}'
```

### Chat App (C#)

```bash
cd chat-app

# Update appsettings.json with your Azure OpenAI credentials

# Restore dependencies
dotnet restore

# Run the application
dotnet run
```

Access the Swagger UI at `https://localhost:5001/swagger`

Test the chat endpoint:
```bash
curl -X POST https://localhost:5001/api/chat \
  -H "Content-Type: application/json" \
  -d '{"message": "Hello, how are you?"}'
```

### Docker Build (Chat App)

```bash
cd chat-app

# Build the image
docker build -t chat-app .

# Run the container
docker run -p 8080:8080 \
  -e AzureOpenAI__Endpoint="https://your-aoai.openai.azure.us/" \
  -e AzureOpenAI__ApiKey="your-key" \
  -e AzureOpenAI__DeploymentName="your-deployment" \
  chat-app

# Test
curl http://localhost:8080/health
```

## 🔑 Configuration

### Azure OpenAI Configuration

After deployment, configure your Azure OpenAI credentials:

**For Chat App:**
```bash
az webapp config appsettings set \
  --name <web-app-name> \
  --resource-group <resource-group> \
  --settings \
    AzureOpenAI__Endpoint="https://your-aoai.openai.azure.us/" \
    AzureOpenAI__ApiKey="your-api-key" \
    AzureOpenAI__DeploymentName="your-deployment-name"
```

**Environment Variables:**
- `AzureOpenAI__Endpoint` - Azure OpenAI endpoint (Azure Government)
- `AzureOpenAI__ApiKey` - API key
- `AzureOpenAI__DeploymentName` - Model deployment name
- `AzureOpenAI__ApiVersion` - API version (default: 2024-02-15-preview)

## 📊 Monitoring

### Application Insights

Both the Function App and Chat App are configured with Application Insights for monitoring:

```bash
# View Function App logs
az webapp log tail --name <function-app-name> --resource-group <rg-name>

# View Chat App logs
az webapp log tail --name <web-app-name> --resource-group <rg-name>

# Query Application Insights
az monitor app-insights query \
  --app <app-insights-name> \
  --resource-group <rg-name> \
  --analytics-query "requests | take 10"
```

## 🧪 Testing

### MCP Function Endpoints

**GET /api/mcp** - Status check
```bash
curl https://<function-app>.azurewebsites.us/api/mcp
```

**POST /api/mcp** - Process MCP request
```bash
curl -X POST https://<function-app>.azurewebsites.us/api/mcp \
  -H "Content-Type: application/json" \
  -H "x-functions-key: <function-key>" \
  -d '{"action": "process", "data": {"text": "Hello MCP"}}'
```

### Chat App Endpoints

**GET /health** - Health check
```bash
curl https://<web-app>.azurewebsites.us/health
```

**POST /api/chat** - Chat with AI
```bash
curl -X POST https://<web-app>.azurewebsites.us/api/chat \
  -H "Content-Type: application/json" \
  -d '{"message": "Tell me about Azure OpenAI"}'
```

## 🔐 Security

- HTTPS enforced for all endpoints
- TLS 1.2 minimum
- Azure Function uses function-level authentication
- API keys secured in Azure Key Vault (recommended for production)
- Container Registry with admin credentials
- Public network access can be restricted via network rules

## 🌐 Azure Government vs Commercial Azure

This solution is configured for Azure Government by default. To use with commercial Azure:

1. Update cloud configuration:
   ```bash
   az cloud set --name AzureCloud
   az login
   ```

2. Update parameters in `infra/main.parameters.json`:
   ```json
   {
     "location": {
       "value": "eastus"
     }
   }
   ```

3. Update endpoints in Chat App to use commercial Azure endpoints

## 🧹 Cleanup

Remove all deployed resources:

```bash
az group delete --name mcp-starter-rg --yes --no-wait
```

## 📚 Documentation

- [MCP Function Documentation](./mcp-function/README.md)
- [Chat App Documentation](./chat-app/README.md)
- [Infrastructure Documentation](./infra/README.md)
- [Deployment Scripts Documentation](./scripts/README.md)

## 🤝 Contributing

Contributions are welcome! Please feel free to submit issues and pull requests.

## 📄 License

This project is licensed under the terms in the LICENSE file.

## 🔗 Resources

- [Azure Functions Documentation](https://docs.microsoft.com/azure/azure-functions/)
- [Azure OpenAI Service](https://docs.microsoft.com/azure/cognitive-services/openai/)
- [Azure Government Documentation](https://docs.microsoft.com/azure/azure-government/)
- [Bicep Documentation](https://docs.microsoft.com/azure/azure-resource-manager/bicep/)
- [Model Context Protocol (MCP)](https://modelcontextprotocol.io/)
