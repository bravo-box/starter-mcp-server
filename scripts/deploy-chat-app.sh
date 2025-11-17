#!/bin/bash

# Deploy Chat App Script
# This script builds and deploys the C# Chat App container

set -e

# Configuration
RESOURCE_GROUP="${RESOURCE_GROUP:-mcp-starter-rg}"
OUTPUTS_FILE="${OUTPUTS_FILE:-deployment-outputs.json}"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}=== MCP Starter - Chat App Deployment ===${NC}"
echo ""

# Check if Azure CLI is installed
if ! command -v az &> /dev/null; then
    echo -e "${RED}Error: Azure CLI is not installed${NC}"
    exit 1
fi

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo -e "${RED}Error: Docker is not installed${NC}"
    echo "Please install Docker: https://docs.docker.com/get-docker/"
    exit 1
fi

# Get deployment info from outputs
if [ -f "$OUTPUTS_FILE" ]; then
    WEB_APP_NAME=$(jq -r '.webAppName.value' "$OUTPUTS_FILE")
    echo "Web App Name: $WEB_APP_NAME"
else
    echo -e "${YELLOW}Warning: $OUTPUTS_FILE not found${NC}"
    read -p "Enter Web App name: " WEB_APP_NAME
fi

if [ -z "$WEB_APP_NAME" ]; then
    echo -e "${RED}Error: Web App name is required${NC}"
    exit 1
fi

# Get container registry info
echo "Getting container registry information..."
REGISTRY_NAME=$(az webapp config container show \
    --name "$WEB_APP_NAME" \
    --resource-group "$RESOURCE_GROUP" \
    --query '[0].value' -o tsv | cut -d'/' -f1)

if [ -z "$REGISTRY_NAME" ]; then
    echo -e "${RED}Error: Could not determine container registry${NC}"
    exit 1
fi

echo "Container Registry: $REGISTRY_NAME"

# Login to ACR
echo ""
echo -e "${GREEN}Logging in to Azure Container Registry...${NC}"
az acr login --name "$REGISTRY_NAME"

# Build and push container
echo ""
echo -e "${GREEN}Building and pushing container...${NC}"
cd ../chat-app

IMAGE_NAME="${REGISTRY_NAME}.azurecr.io/chat-app:latest"
echo "Building image: $IMAGE_NAME"

docker build -t "$IMAGE_NAME" .
docker push "$IMAGE_NAME"

# Update web app to use new image
echo ""
echo -e "${GREEN}Updating web app configuration...${NC}"
az webapp config container set \
    --name "$WEB_APP_NAME" \
    --resource-group "$RESOURCE_GROUP" \
    --docker-custom-image-name "$IMAGE_NAME" \
    --output table

# Restart web app
echo ""
echo -e "${GREEN}Restarting web app...${NC}"
az webapp restart \
    --name "$WEB_APP_NAME" \
    --resource-group "$RESOURCE_GROUP" \
    --output table

echo ""
echo -e "${GREEN}Chat App deployed successfully!${NC}"

# Get web app URL
WEB_APP_URL=$(az webapp show \
    --name "$WEB_APP_NAME" \
    --resource-group "$RESOURCE_GROUP" \
    --query defaultHostName -o tsv)

if [ -n "$WEB_APP_URL" ]; then
    echo ""
    echo -e "${GREEN}Web App URL:${NC}"
    echo "https://$WEB_APP_URL"
    echo ""
    echo -e "${GREEN}Health Check:${NC}"
    echo "https://$WEB_APP_URL/health"
    echo ""
    echo -e "${GREEN}Swagger UI:${NC}"
    echo "https://$WEB_APP_URL/swagger"
fi
