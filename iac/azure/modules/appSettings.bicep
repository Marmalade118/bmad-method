param appServiceName string
param settings object = {}

resource appService 'Microsoft.Web/sites@2020-06-01' existing = {
  name: appServiceName
}

resource appSettings 'Microsoft.Web/sites/config@2022-03-01' = {
  name: 'appsettings'
  kind: 'string'
  parent: appService
  properties: settings
}
