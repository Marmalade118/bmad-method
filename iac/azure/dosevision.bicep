targetScope = 'subscription'

var requiredTags  = {
  Sector1: 'New Markets'
  Sector2: 'Tracerco'
 }

param location string = deployment().location

param application string = 'dosevision'

var apiApplicationName = '${application}api'
var uiApplicationName = '${application}ui'
var backgroundApplicationName = '${application}background'

param CNAME string = ''

param openIdAuthority string = 'https://sso.tracerco.com'
param openIdMetadataAddress string = 'https://sso.tracerco.com/oidc/.well-known/openid-configuration'
param openIdClientId string = 'dosevisionweb-dev'

param tracercoIdentityUrl string
param tracercoIdentityClientId string

param supportEmail string = 'dosevision@tracerco.com'

@secure()
param tracercoIdentitySecret string

@allowed([
  'dev'
  'uat'
  'prod'
])
param environment string = 'dev' 

param rgName string = 'rg-${application}-${environment}'

module deploymentGroupModule 'modules/resourceGroup.bicep' = {
  name: '${deployment().name}-resourcegroup'
  scope: subscription()
  params: {
    location: location
    application: application
    environment: environment
    businessUnit: 'assurance'
    tags: requiredTags
  }
}

module managedIdentityModel 'modules/managedIdentity.bicep' = {
  name: '${deployment().name}-managedidentity'
  scope: resourceGroup(rgName)
  params: {
    location: location
    application: application
    environment: environment
    businessUnit: 'assurance'
    tags: requiredTags
  }
  dependsOn: [
    deploymentGroupModule
  ]
}


module applicationInsightsModule 'modules/applicationInsights.bicep' = {
  name: '${deployment().name}-applicationinsights'
  scope: resourceGroup(rgName)
  params: {
    application: application
    location: location
    environment: environment
  }
  dependsOn: [
    deploymentGroupModule
  ]
}

module serverFarmModule 'modules/serverfarm.bicep' = {
  name: '${deployment().name}-appserviceplan'
  scope: resourceGroup(rgName)
  params: {
    location: location
    application: application
    environment: environment
    businessUnit: 'assurance'
    additionalTags: requiredTags
  }
  dependsOn: [
    deploymentGroupModule
  ]
}

module uiAppService 'modules/appService.bicep' = {
  name: '${deployment().name}-ui-appservice'
  scope: resourceGroup(rgName)
  params: {
    location: location
    application: uiApplicationName
    environment: environment
    businessUnit: 'assurance'
    additionalTags: requiredTags
    serverFarmId: serverFarmModule.outputs.serverFarmId
    msi: managedIdentityModel.outputs.managedIdentityId
    stack: 'NODE|18-lts'
    appCommandLine: 'pm2 serve /home/site/wwwroot --spa --no-daemon'
  }
  dependsOn: [
    serverFarmModule
    managedIdentityModel
  ]
}

module msMapsModule 'modules/msMaps.bicep' = {
    scope: resourceGroup(rgName)
    name: '${deployment().name}-api-map'
    params: {
        application: application
        environment: environment
    }
    dependsOn: [
      deploymentGroupModule
    ]
}

module apiAppService 'modules/appService.bicep' = {
  name: '${deployment().name}-api-appservice'
  scope: resourceGroup(rgName)
  params: {
    location: location
    application: apiApplicationName
    environment: environment
    businessUnit: 'assurance'
    additionalTags: requiredTags
    serverFarmId: serverFarmModule.outputs.serverFarmId
    msi: managedIdentityModel.outputs.managedIdentityId
    allowedCorsOrigins: [ 'https://${uiAppService.outputs.appServiceDefaultHostName}', 'http://localhost:4200', 'https://dosevision.tracerco.com' ]
  }
  dependsOn: [
    serverFarmModule
    managedIdentityModel
    uiAppService
    msMapsModule
  ]
}

module storage 'modules/storage.bicep' = {
  scope: resourceGroup(rgName)
  name: '${deployment().name}-storageaccount'
  params: {
    location: location
    storageAccountName: 'stdosevision${environment}'
  }
  dependsOn: [
    deploymentGroupModule
  ]
}


module apiAvailabilityTest 'modules/applicationInsightsAvailabilityTest.bicep' = {
  scope: resourceGroup(rgName)
  name: '${deployment().name}-api-availabilitytest'
  params: {
    applicationInsightsInstanceResourceId: applicationInsightsModule.outputs.resourceId
    location: location
    application: 'dvi'
    testName: 'API Test'
    requestUrl: apiAppService.outputs.appServiceDefaultHostName
  }
  dependsOn: [
    applicationInsightsModule
  ]
}

module uiAvailabilityTest 'modules/applicationInsightsAvailabilityTest.bicep' = {
  scope: resourceGroup(rgName)
  name: '${deployment().name}-ui-availabilitytest'
  params: {
    applicationInsightsInstanceResourceId: applicationInsightsModule.outputs.resourceId
    location: location
    application: 'dvi'
    testName: 'UI Test'
    requestUrl: uiAppService.outputs.appServiceDefaultHostName
  }
  dependsOn: [
    applicationInsightsModule
  ]
}

module sqls 'modules/sqlServer.bicep' = {
  scope: resourceGroup(rgName)
  name: '${deployment().name}-sqlserver'
  params: {
    location: location
    environment: environment
  }
  dependsOn: [
    deploymentGroupModule
  ]
}

module db 'modules/sqlDatabase.bicep' = {
  scope: resourceGroup(rgName)
  name: '${deployment().name}-sqldatabase'
  params: {
    location: location
    environment: environment
  }
  dependsOn: [
    sqls
  ]
}

module firewall 'modules/sqlServerFirewallRule.bicep' = {
  scope: resourceGroup(rgName)
  name: '${deployment().name}-sqlserver-firwall'
  params: {
    sqlName: sqls.outputs.name
  }
  dependsOn: [
    sqls
  ]
}

module apiAppConnectionStrings 'modules/appServiceConnectionStrings.bicep' = {
  scope: resourceGroup(rgName)
  name: '${deployment().name}-api-connectionstrings'
  params: {
    appServiceName: apiAppService.outputs.appServiceName
    connectionStrings: {
      DefaultConnection: {
        value: db.outputs.connectionString
        type: 'SQLAzure'
      }
    }
  }
  dependsOn: [
    sqls
    apiAppService
  ]
}

module apiAppSettings 'modules/appSettings.bicep' = {
  scope: resourceGroup(rgName)
  name: '${deployment().name}-api-appsettings'
  params: {
    appServiceName: apiAppService.outputs.appServiceName
    settings: {
      WEBSITE_RUN_FROM_PACKAGE: '1'
      APPINSIGHTS_INSTRUMENTATIONKEY: applicationInsightsModule.outputs.instrumentationKey
      APPINSIGHTS_PROFILERFEATURE_VERSION: '1.0.0'
      APPINSIGHTS_SNAPSHOTFEATURE_VERSION: '1.0.0'
      APPLICATIONINSIGHTS_CONNECTION_STRING: applicationInsightsModule.outputs.connectionString
      ApplicationInsightsAgent_EXTENSION_VERSION: '~3'
      DiagnosticServices_EXTENSION_VERSION: '~3'
      InstrumentationEngine_EXTENSION_VERSION: 'disabled'
      SnapshotDebugger_EXTENSION_VERSION: 'disabled'
      XDT_MicrosoftApplicationInsights_BaseExtensions: 'disabled'
      XDT_MicrosoftApplicationInsights_Mode: 'recommended'
      XDT_MicrosoftApplicationInsights_PreemptSdk: 'disabled'
      AZURE_CLIENT_ID: managedIdentityModel.outputs.managedIdentityClientId //Which user managed identity should the app use by default.
      IdentityManagementClient__BaseUrl: tracercoIdentityUrl
      IdentityManagementClient__ClientId: tracercoIdentityClientId
      IdentityManagementClient__ClientSecret: tracercoIdentitySecret
      IdentityManagementClient__TokenEndpoint: '/oidc/connect/token'
      AzureStorage__ConnectionString: 'DefaultEndpointsProtocol=https;AccountName=${storage.outputs.name};AccountKey=${storage.outputs.accountKey}'
      Serilog__WriteTo__1__Args__connectionString: 'DefaultEndpointsProtocol=https;AccountName=${storage.outputs.name};AccountKey=${storage.outputs.accountKey}'
      OpenID__Authority: openIdAuthority
      OpenID__MetadataAddress: openIdMetadataAddress
      OpenID__ClientId: openIdClientId
      AzureMaps__SubscriptionKey: msMapsModule.outputs.msMapsKey
      Common__Url: 'https://${empty(CNAME) ? uiAppService.outputs.appServiceDefaultHostName : CNAME}/'
      Common__SupportEmail: supportEmail
      DOTNET_ENVIRONMENT: environment == 'dev' ? 'Development' : null
      ASPNETCORE_ENVIRONMENT: environment == 'dev' ? 'Development' : null
    }
  }
  dependsOn: [
    applicationInsightsModule
    apiAppService
    msMapsModule
  ]
}

module backgroundAppService 'modules/functionApp.bicep' = {
  name: '${deployment().name}-background-appservice'
  scope: resourceGroup(rgName)
  params: {
    location: location
    application: backgroundApplicationName
    environment: environment
    businessUnit: 'assurance'
    additionalTags: requiredTags
    serverFarmId: serverFarmModule.outputs.serverFarmId
    msi: managedIdentityModel.outputs.managedIdentityId
    stack: 'DOTNET-ISOLATED|8.0'
  }
  dependsOn: [
    serverFarmModule
    managedIdentityModel
  ]
}

module backgroundAppServiceSettings 'modules/appSettings.bicep' = {
  scope: resourceGroup(rgName)
  name: '${deployment().name}-background-appsettings'
  params: {
    appServiceName: backgroundAppService.outputs.appServiceName
    settings: {
      APPINSIGHTS_INSTRUMENTATIONKEY: applicationInsightsModule.outputs.instrumentationKey
      APPINSIGHTS_PROFILERFEATURE_VERSION: '1.0.0'
      APPINSIGHTS_SNAPSHOTFEATURE_VERSION: '1.0.0'
      APPLICATIONINSIGHTS_CONNECTION_STRING: applicationInsightsModule.outputs.connectionString
      ASPNETCORE_ENVIRONMENT: environment == 'dev' ? 'Development' : null
      COMMON_SUPPORTEMAIL: supportEmail
      AZURE_CLIENT_ID: managedIdentityModel.outputs.managedIdentityClientId //Which user managed identity should the app use by default.
      ApplicationInsightsAgent_EXTENSION_VERSION: '~3'
      AzureStorage__ConnectionString: 'DefaultEndpointsProtocol=https;AccountName=${storage.outputs.name};AccountKey=${storage.outputs.accountKey}'
      AzureWebJobsStorage: 'DefaultEndpointsProtocol=https;AccountName=${storage.outputs.name};AccountKey=${storage.outputs.accountKey}'
      Common__Url: 'https://${empty(CNAME) ? uiAppService.outputs.appServiceDefaultHostName : CNAME}/'
      Common__SupportEmail: supportEmail
      DOTNET_ENVIRONMENT: environment == 'dev' ? 'Development' : null
      DiagnosticServices_EXTENSION_VERSION: '~3'
      FUNCTIONS_EXTENSION_VERSION: '~4'
      FUNCTIONS_WORKER_RUNTIME: 'dotnet-isolated'
      InstrumentationEngine_EXTENSION_VERSION: 'disabled'
      AzureMaps__SubscriptionKey: msMapsModule.outputs.msMapsKey
      OpenID__Authority: openIdAuthority
      OpenID__ClientId: openIdClientId
      OpenID__MetadataAddress: openIdMetadataAddress
      SnapshotDebugger_EXTENSION_VERSION: 'disabled'
      IdentityManagementClient__BaseUrl: tracercoIdentityUrl
      IdentityManagementClient__ClientId: tracercoIdentityClientId
      IdentityManagementClient__ClientSecret: tracercoIdentitySecret
      IdentityManagementClient__TokenEndpoint: '/oidc/connect/token'
      WEBSITE_CONTENTAZUREFILECONNECTIONSTRING: 'DefaultEndpointsProtocol=https;AccountName=${storage.outputs.name};AccountKey=${storage.outputs.accountKey}'
      WEBSITE_CONTENTSHARE: backgroundAppService.outputs.appServiceName
      WEBSITE_RUN_FROM_PACKAGE: '1'
      WEBSITE_USE_PLACEHOLDER_DOTNETISOLATED: 1
      XDT_MicrosoftApplicationInsights_BaseExtensions: 'disabled'
      XDT_MicrosoftApplicationInsights_Mode: 'recommended'
      XDT_MicrosoftApplicationInsights_PreemptSdk: 'disabled'
      ConnectionStrings__DefaultConnection: db.outputs.connectionString
    }
  }
  dependsOn: [
    applicationInsightsModule
    backgroundAppService
  ]
}


module uiAppSettings 'modules/appSettings.bicep' = {
  scope: resourceGroup(rgName)
  name: '${deployment().name}-ui-appsettings'
  params: {
    appServiceName: uiAppService.outputs.appServiceName
    settings: {
      WEBSITE_RUN_FROM_PACKAGE: '1'
      APPINSIGHTS_INSTRUMENTATIONKEY: applicationInsightsModule.outputs.instrumentationKey
      APPINSIGHTS_PROFILERFEATURE_VERSION: '1.0.0'
      APPINSIGHTS_SNAPSHOTFEATURE_VERSION: '1.0.0'
      APPLICATIONINSIGHTS_CONNECTION_STRING: applicationInsightsModule.outputs.connectionString
      ApplicationInsightsAgent_EXTENSION_VERSION: '~2'
      DiagnosticServices_EXTENSION_VERSION: '~3'
      InstrumentationEngine_EXTENSION_VERSION: 'disabled'
      SnapshotDebugger_EXTENSION_VERSION: 'disabled'
      XDT_MicrosoftApplicationInsights_BaseExtensions: 'disabled'
      XDT_MicrosoftApplicationInsights_Mode: 'recommended'
      XDT_MicrosoftApplicationInsights_PreemptSdk: 'disabled'
    }
  }
  dependsOn: [
    applicationInsightsModule
    uiAppService
  ]
}

output resourceGroupName string = deploymentGroupModule.outputs.resourceGroupName
output apiWebAppName string = apiAppService.outputs.appServiceName
output functionAppName string = backgroundAppService.outputs.appServiceName