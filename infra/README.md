# Infrastructure

This directory contains Bicep templates for deploying the MCP starter server infrastructure to Azure.

## Resources Deployed

- **Azure Function App** (Linux, Python 3.11) - Hosts the MCP function
- **Azure Web App** (Linux, Container) - Hosts the Chat App
- **Azure OpenAI** - Provides AI capabilities
- **Container Registry** - Stores the Chat App container image
- **Storage Account** - Required for Azure Functions
- **Application Insights** - Monitoring and telemetry for both apps

## Files

- `main.bicep` - Main orchestration template
- `main.parameters.json` - Default parameters for deployment
- `modules/function-app.bicep` - Azure Function App module
- `modules/openai.bicep` - Azure OpenAI module
- `modules/web-app.bicep` - Azure Web App with Container Registry module

## Parameters

| Parameter | Description | Default |
|-----------|-------------|---------|
| environmentName | Environment name (dev, test, prod) | dev |
| location | Azure region | usgovvirginia |
| openAIModelName | OpenAI model to deploy | gpt-35-turbo |
| openAIModelVersion | Model version | 0613 |
| openAIDeploymentCapacity | Deployment capacity (TPM) | 30 |

## Deployment

### Prerequisites

- Azure CLI installed
- Logged in to Azure Government: `az cloud set --name AzureUSGovernment && az login`
- Contributor access to an Azure subscription

### Deploy Infrastructure

Using the deployment script:
```bash
cd ../scripts
./deploy-infrastructure.sh
```

Or manually:
```bash
# Create resource group
az group create --name mcp-starter-rg --location usgovvirginia

# Deploy infrastructure
az deployment group create \
  --resource-group mcp-starter-rg \
  --template-file main.bicep \
  --parameters main.parameters.json
```

### Custom Parameters

You can override parameters:
```bash
az deployment group create \
  --resource-group mcp-starter-rg \
  --template-file main.bicep \
  --parameters environmentName=prod location=usgovvirginia
```

## Outputs

After deployment, the following outputs are available:

- `functionAppName` - Name of the deployed Function App
- `functionAppUrl` - URL of the Function App
- `webAppName` - Name of the deployed Web App
- `webAppUrl` - URL of the Web App
- `openAIEndpoint` - Azure OpenAI endpoint URL
- `openAIDeploymentName` - Name of the OpenAI deployment

View outputs:
```bash
az deployment group show \
  --resource-group mcp-starter-rg \
  --name <deployment-name> \
  --query properties.outputs
```

## Azure Government Configuration

The templates are pre-configured for Azure Government cloud:
- Default location: `usgovvirginia`
- Uses Azure Government endpoints
- Compatible with Azure Government OpenAI service

To use in commercial Azure, update the `location` parameter to a commercial region.
