param location string

param application string

@allowed([
  'dev'
  'uat'
  'prod'
])
param environment string = 'dev' 

param businessUnit string = 'digital'

var appServicePlanName = 'plan-${application}-${environment}'
param additionalTags object = {}


resource appServicePlan 'Microsoft.Web/serverfarms@2020-06-01' = {
  name: appServicePlanName
  location: location
  properties: {
    reserved: true
  }
  sku: {
    name: 'B2'
  }
  kind: 'linux'
  tags: union(additionalTags, {
    application: application
    environment: environment
    businessUnit: businessUnit
  })
}

output serverFarmId string = appServicePlan.id
