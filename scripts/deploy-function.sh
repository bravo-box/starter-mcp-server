#!/bin/bash

# Deploy Function App Script
# This script deploys the Python Azure Function

set -e

# Configuration
RESOURCE_GROUP="${RESOURCE_GROUP:-mcp-starter-rg}"
OUTPUTS_FILE="${OUTPUTS_FILE:-deployment-outputs.json}"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}=== MCP Starter - Function App Deployment ===${NC}"
echo ""

# Check if Azure CLI is installed
if ! command -v az &> /dev/null; then
    echo -e "${RED}Error: Azure CLI is not installed${NC}"
    exit 1
fi

# Check if func tools are installed
if ! command -v func &> /dev/null; then
    echo -e "${RED}Error: Azure Functions Core Tools not installed${NC}"
    echo "Install from: https://docs.microsoft.com/azure/azure-functions/functions-run-local"
    exit 1
fi

# Get function app name from outputs
if [ -f "$OUTPUTS_FILE" ]; then
    FUNCTION_APP_NAME=$(jq -r '.functionAppName.value' "$OUTPUTS_FILE")
    echo "Function App Name: $FUNCTION_APP_NAME"
else
    echo -e "${YELLOW}Warning: $OUTPUTS_FILE not found${NC}"
    read -p "Enter Function App name: " FUNCTION_APP_NAME
fi

if [ -z "$FUNCTION_APP_NAME" ]; then
    echo -e "${RED}Error: Function App name is required${NC}"
    exit 1
fi

echo ""
echo -e "${GREEN}Deploying function app...${NC}"

# Navigate to function directory
cd ../mcp-function

# Create virtual environment and install dependencies
echo "Installing dependencies..."
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt

# Deploy function
echo "Deploying to Azure..."
func azure functionapp publish "$FUNCTION_APP_NAME" --python

deactivate

echo ""
echo -e "${GREEN}Function App deployed successfully!${NC}"

# Get function URL
FUNCTION_URL=$(az functionapp function show \
    --name "$FUNCTION_APP_NAME" \
    --resource-group "$RESOURCE_GROUP" \
    --function-name mcp \
    --query invokeUrlTemplate -o tsv 2>/dev/null || echo "")

if [ -n "$FUNCTION_URL" ]; then
    echo ""
    echo -e "${GREEN}Function URL:${NC}"
    echo "$FUNCTION_URL"
    echo ""
    echo -e "${YELLOW}Note: You'll need to add the function key to access it${NC}"
    echo "Get the key with:"
    echo "  az functionapp keys list --name $FUNCTION_APP_NAME --resource-group $RESOURCE_GROUP"
fi
