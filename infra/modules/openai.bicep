// Parameters
@description('The name of the Azure OpenAI account')
param accountName string

@description('The location for the Azure OpenAI resource')
param location string

@description('The model name to deploy')
param modelName string

@description('The model version to deploy')
param modelVersion string

@description('The deployment capacity')
param deploymentCapacity int = 30

// Variables
var deploymentName = '${modelName}-deployment'

// Azure OpenAI Account
resource openAIAccount 'Microsoft.CognitiveServices/accounts@2023-05-01' = {
  name: accountName
  location: location
  sku: {
    name: 'S0'
  }
  kind: 'OpenAI'
  properties: {
    customSubDomainName: accountName
    publicNetworkAccess: 'Enabled'
    networkAcls: {
      defaultAction: 'Allow'
    }
  }
}

// Model Deployment
resource deployment 'Microsoft.CognitiveServices/accounts/deployments@2023-05-01' = {
  parent: openAIAccount
  name: deploymentName
  sku: {
    name: 'Standard'
    capacity: deploymentCapacity
  }
  properties: {
    model: {
      format: 'OpenAI'
      name: modelName
      version: modelVersion
    }
  }
}

// Outputs
output endpoint string = openAIAccount.properties.endpoint
output key string = openAIAccount.listKeys().key1
output deploymentName string = deployment.name
output accountName string = openAIAccount.name
