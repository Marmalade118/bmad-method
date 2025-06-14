targetScope = 'subscription'

param location string = deployment().location

param application string

@allowed([
  'dev'
  'uat'
  'prod'
])
param environment string = 'dev' 

param businessUnit string = 'digital'

param rgName string = 'rg-${application}-${environment}'

param tags object = {}


resource rg 'Microsoft.Resources/resourceGroups@2021-01-01' = {
  name: rgName
  location: location
  tags: union(tags, {
    application: application
    environment: environment
    businessUnit: businessUnit
  })
}

output resourceGroupName string = rg.name
output resourceGroupLocation string = rg.location
