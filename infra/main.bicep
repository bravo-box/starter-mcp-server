// Parameters
@description('The name of the environment (e.g., dev, test, prod)')
param environmentName string = 'dev'

@description('The location for all resources')
param location string = resourceGroup().location

@description('The Azure OpenAI deployment model name')
param openAIModelName string = 'gpt-35-turbo'

@description('The Azure OpenAI deployment model version')
param openAIModelVersion string = '0613'

@description('The Azure OpenAI deployment capacity')
param openAIDeploymentCapacity int = 30

// Variables
var resourceBaseName = 'mcp-${environmentName}-${uniqueString(resourceGroup().id)}'
var functionAppName = '${resourceBaseName}-func'
var webAppName = '${resourceBaseName}-web'
var openAIAccountName = '${resourceBaseName}-aoai'

// Modules
module functionApp 'modules/function-app.bicep' = {
  name: 'functionAppDeployment'
  params: {
    functionAppName: functionAppName
    location: location
    environmentName: environmentName
  }
}

module openAI 'modules/openai.bicep' = {
  name: 'openAIDeployment'
  params: {
    accountName: openAIAccountName
    location: location
    modelName: openAIModelName
    modelVersion: openAIModelVersion
    deploymentCapacity: openAIDeploymentCapacity
  }
}

module webApp 'modules/web-app.bicep' = {
  name: 'webAppDeployment'
  params: {
    webAppName: webAppName
    location: location
    environmentName: environmentName
    openAIEndpoint: openAI.outputs.endpoint
    openAIKey: openAI.outputs.key
    openAIDeploymentName: openAI.outputs.deploymentName
  }
}

// Outputs
output functionAppName string = functionApp.outputs.functionAppName
output functionAppUrl string = functionApp.outputs.functionAppUrl
output webAppName string = webApp.outputs.webAppName
output webAppUrl string = webApp.outputs.webAppUrl
output openAIEndpoint string = openAI.outputs.endpoint
output openAIDeploymentName string = openAI.outputs.deploymentName
