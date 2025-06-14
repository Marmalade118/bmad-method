param location string

param application string

param msi string

@allowed([
  'dev'
  'uat'
  'prod'
])
param environment string = 'dev' 

param businessUnit string = 'digital'

var appServiceName = 'func-${application}-${environment}'
param additionalTags object = {}

param serverFarmId string

param stack string = 'DOTNETCORE|9.0'
param appCommandLine string = ''

param allowedCorsOrigins array = [ ]

resource appService 'Microsoft.Web/sites@2022-09-01' = {
  name: appServiceName
  location: location
  kind: 'functionapp,linux'
  properties: {
    serverFarmId: serverFarmId
    siteConfig: {
      linuxFxVersion: stack
      ftpsState: 'Disabled'
      alwaysOn: true
      appCommandLine: appCommandLine
      cors: {
        allowedOrigins: allowedCorsOrigins
        supportCredentials: true
      }
    }
    httpsOnly: true
  }
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${msi}': {}
    }
  }
  tags: union(additionalTags, {
    application: application
    environment: environment
    businessUnit: businessUnit
  })
}

output appServiceDefaultHostName string = appService.properties.defaultHostName
output appServiceName string = appService.name
