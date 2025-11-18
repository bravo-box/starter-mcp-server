// Parameters
@description('The name of the web app')
param webAppName string

@description('The location for all resources')
param location string

@description('The environment name')
param environmentName string

@description('The Azure OpenAI endpoint')
@secure()
param openAIEndpoint string

@description('The Azure OpenAI key')
@secure()
param openAIKey string

@description('The Azure OpenAI deployment name')
param openAIDeploymentName string

// Variables
var appServicePlanName = '${webAppName}-plan'
var applicationInsightsName = '${webAppName}-ai'
var containerRegistryName = 'cr${replace(webAppName, '-', '')}${uniqueString(resourceGroup().id)}'

// Container Registry
resource containerRegistry 'Microsoft.ContainerRegistry/registries@2023-01-01-preview' = {
  name: take(containerRegistryName, 50)
  location: location
  sku: {
    name: 'Basic'
  }
  properties: {
    adminUserEnabled: true
  }
}

// App Service Plan for Linux Containers
resource appServicePlan 'Microsoft.Web/serverfarms@2023-01-01' = {
  name: appServicePlanName
  location: location
  sku: {
    name: 'B1'
    tier: 'Basic'
  }
  kind: 'linux'
  properties: {
    reserved: true
  }
}

// Application Insights
resource applicationInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: applicationInsightsName
  location: location
  kind: 'web'
  properties: {
    Application_Type: 'web'
    Request_Source: 'rest'
  }
}

// Web App
resource webApp 'Microsoft.Web/sites@2023-01-01' = {
  name: webAppName
  location: location
  kind: 'app,linux,container'
  properties: {
    serverFarmId: appServicePlan.id
    siteConfig: {
      linuxFxVersion: 'DOCKER|mcr.microsoft.com/dotnet/samples:aspnetapp'
      appSettings: [
        {
          name: 'WEBSITES_ENABLE_APP_SERVICE_STORAGE'
          value: 'false'
        }
        {
          name: 'DOCKER_REGISTRY_SERVER_URL'
          value: 'https://${containerRegistry.properties.loginServer}'
        }
        {
          name: 'DOCKER_REGISTRY_SERVER_USERNAME'
          value: containerRegistry.listCredentials().username
        }
        {
          name: 'DOCKER_REGISTRY_SERVER_PASSWORD'
          value: containerRegistry.listCredentials().passwords[0].value
        }
        {
          name: 'AzureOpenAI__Endpoint'
          value: openAIEndpoint
        }
        {
          name: 'AzureOpenAI__ApiKey'
          value: openAIKey
        }
        {
          name: 'AzureOpenAI__DeploymentName'
          value: openAIDeploymentName
        }
        {
          name: 'AzureOpenAI__ApiVersion'
          value: '2024-02-15-preview'
        }
        {
          name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
          value: applicationInsights.properties.InstrumentationKey
        }
        {
          name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
          value: applicationInsights.properties.ConnectionString
        }
      ]
      ftpsState: 'Disabled'
      minTlsVersion: '1.2'
      http20Enabled: true
    }
    httpsOnly: true
  }
}

// Outputs
output webAppName string = webApp.name
output webAppUrl string = 'https://${webApp.properties.defaultHostName}'
output webAppId string = webApp.id
output containerRegistryName string = containerRegistry.name
output containerRegistryLoginServer string = containerRegistry.properties.loginServer
