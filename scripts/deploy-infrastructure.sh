#!/bin/bash

# Deploy Infrastructure Script
# This script deploys the Azure infrastructure using Bicep templates

set -e

# Configuration
RESOURCE_GROUP="${RESOURCE_GROUP:-mcp-starter-rg}"
LOCATION="${LOCATION:-usgovvirginia}"
ENVIRONMENT="${ENVIRONMENT:-dev}"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}=== MCP Starter - Infrastructure Deployment ===${NC}"
echo ""

# Check if Azure CLI is installed
if ! command -v az &> /dev/null; then
    echo -e "${RED}Error: Azure CLI is not installed${NC}"
    echo "Please install Azure CLI: https://docs.microsoft.com/cli/azure/install-azure-cli"
    exit 1
fi

# Check if logged in to Azure
if ! az account show &> /dev/null; then
    echo -e "${RED}Error: Not logged in to Azure${NC}"
    echo "Please login using: az login"
    exit 1
fi

# Check if connected to Azure Government
CLOUD=$(az cloud show --query name -o tsv)
if [ "$CLOUD" != "AzureUSGovernment" ]; then
    echo -e "${YELLOW}Warning: Not connected to Azure Government cloud${NC}"
    echo "Current cloud: $CLOUD"
    echo "To connect to Azure Government, run:"
    echo "  az cloud set --name AzureUSGovernment"
    echo "  az login"
    read -p "Continue anyway? (y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

echo "Configuration:"
echo "  Resource Group: $RESOURCE_GROUP"
echo "  Location: $LOCATION"
echo "  Environment: $ENVIRONMENT"
echo ""

# Create resource group if it doesn't exist
echo -e "${GREEN}Creating resource group...${NC}"
az group create \
    --name "$RESOURCE_GROUP" \
    --location "$LOCATION" \
    --output table

echo ""
echo -e "${GREEN}Deploying infrastructure...${NC}"
echo "This may take 10-15 minutes..."

# Deploy infrastructure
DEPLOYMENT_NAME="mcp-deployment-$(date +%Y%m%d-%H%M%S)"

az deployment group create \
    --name "$DEPLOYMENT_NAME" \
    --resource-group "$RESOURCE_GROUP" \
    --template-file ../infra/main.bicep \
    --parameters ../infra/main.parameters.json \
    --parameters environmentName="$ENVIRONMENT" location="$LOCATION" \
    --output table

echo ""
echo -e "${GREEN}Deployment complete!${NC}"
echo ""

# Get outputs
echo -e "${GREEN}Deployment Outputs:${NC}"
az deployment group show \
    --name "$DEPLOYMENT_NAME" \
    --resource-group "$RESOURCE_GROUP" \
    --query properties.outputs \
    --output table

# Save outputs to file
OUTPUTS_FILE="deployment-outputs.json"
az deployment group show \
    --name "$DEPLOYMENT_NAME" \
    --resource-group "$RESOURCE_GROUP" \
    --query properties.outputs \
    --output json > "$OUTPUTS_FILE"

echo ""
echo -e "${GREEN}Outputs saved to: $OUTPUTS_FILE${NC}"
echo ""
echo -e "${YELLOW}Next steps:${NC}"
echo "1. Deploy the Function App: ./deploy-function.sh"
echo "2. Build and deploy the Chat App: ./deploy-chat-app.sh"
