param location string = resourceGroup().location

param application string
param tags object = {}
@allowed([
  'dev'
  'uat'
  'prod'
])
param environment string = 'dev' 

param businessUnit string = 'digital'

var applicationInsightsName = 'appi-dosevision-${environment}'

resource applicationInsights 'microsoft.insights/components@2015-05-01' = {
  name: applicationInsightsName
  location: location
  kind: 'web'
  tags: union(tags, {
    application: application
    environment: environment
    businessUnit: businessUnit
  })
  properties: {
    Application_Type: 'web'
  }
  dependsOn: []
}

output resourceId string = applicationInsights.id
output instrumentationKey string = applicationInsights.properties.InstrumentationKey
output connectionString string = applicationInsights.properties.ConnectionString
