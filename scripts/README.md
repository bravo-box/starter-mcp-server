# Deployment Scripts

This directory contains scripts for deploying the MCP starter server infrastructure and applications to Azure.

## Prerequisites

- Azure CLI installed and configured
- Azure Functions Core Tools (for function deployment)
- Docker (for container deployment)
- Access to Azure Government subscription (or modify for commercial Azure)
- jq (JSON processor) - Install with: `brew install jq` or `apt-get install jq`

## Scripts

### 1. deploy-infrastructure.sh

Deploys the Azure infrastructure using Bicep templates.

**Usage:**
```bash
./deploy-infrastructure.sh
```

**Environment Variables:**
- `RESOURCE_GROUP` - Name of the resource group (default: mcp-starter-rg)
- `LOCATION` - Azure region (default: usgovvirginia)
- `ENVIRONMENT` - Environment name (default: dev)

**Example:**
```bash
RESOURCE_GROUP=my-rg ENVIRONMENT=prod ./deploy-infrastructure.sh
```

**What it deploys:**
- Resource Group
- Azure Function App (Python)
- Azure Web App (Container)
- Azure OpenAI
- Container Registry
- Storage Account
- Application Insights

**Outputs:**
- Creates `deployment-outputs.json` with deployment information
- Displays URLs and resource names

### 2. deploy-function.sh

Deploys the Python Azure Function to the Function App.

**Usage:**
```bash
./deploy-function.sh
```

**Environment Variables:**
- `RESOURCE_GROUP` - Name of the resource group (default: mcp-starter-rg)
- `OUTPUTS_FILE` - Path to outputs file (default: deployment-outputs.json)

**What it does:**
- Reads Function App name from deployment outputs
- Installs Python dependencies
- Deploys function code using Azure Functions Core Tools
- Displays function URL

### 3. deploy-chat-app.sh

Builds and deploys the Chat App container to Azure Web App.

**Usage:**
```bash
./deploy-chat-app.sh
```

**Environment Variables:**
- `RESOURCE_GROUP` - Name of the resource group (default: mcp-starter-rg)
- `OUTPUTS_FILE` - Path to outputs file (default: deployment-outputs.json)

**What it does:**
- Reads Web App and Container Registry names from deployment outputs
- Logs into Azure Container Registry
- Builds Docker image
- Pushes image to ACR
- Updates Web App configuration
- Restarts Web App
- Displays Web App URL and endpoints

## Complete Deployment Workflow

Run the scripts in order:

```bash
# 1. Deploy infrastructure
./deploy-infrastructure.sh

# 2. Deploy function app
./deploy-function.sh

# 3. Deploy chat app
./deploy-chat-app.sh
```

## Azure Government vs Commercial Azure

The scripts are configured for Azure Government by default. To use with commercial Azure:

1. Change the cloud:
   ```bash
   az cloud set --name AzureCloud
   az login
   ```

2. Update the location:
   ```bash
   LOCATION=eastus ./deploy-infrastructure.sh
   ```

## Troubleshooting

### Azure CLI not authenticated
```bash
az login
```

### Wrong cloud
```bash
az cloud set --name AzureUSGovernment
az login
```

### Function deployment fails
- Ensure Azure Functions Core Tools v4 is installed
- Check Python version (3.11 required)
- Verify the function app is running

### Container deployment fails
- Ensure Docker is running
- Check ACR credentials
- Verify Web App is configured for containers

### View deployment logs
```bash
# Function App logs
az webapp log tail --name <function-app-name> --resource-group <rg-name>

# Web App logs
az webapp log tail --name <web-app-name> --resource-group <rg-name>
```

## Cleanup

To remove all deployed resources:

```bash
az group delete --name mcp-starter-rg --yes --no-wait
```
