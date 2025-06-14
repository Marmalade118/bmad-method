param appServiceName string
param connectionStrings object = {}

resource appService 'Microsoft.Web/sites@2020-06-01' existing = {
  name: appServiceName
}


resource adminBackgroundAppServiceName_connectionstrings 'Microsoft.Web/sites/config@2022-03-01' = {
  parent: appService
  name: 'connectionstrings'
  properties: connectionStrings
}
