param location string = resourceGroup().location

param application string
param tags object = {}
@allowed([
  'dev'
  'uat'
  'prod'
])
param environment string = 'dev' 

var name = 'id-${application}-${environment}'

param businessUnit string = 'digital'

resource managedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2022-01-31-preview' = {
  name: name
  location: location
  tags: union(tags, {
    application: application
    environment: environment
    businessUnit: businessUnit
  })
}

output managedIdentityId string = managedIdentity.id
output managedIdentityName string = name
output managedIdentityClientId string = managedIdentity.properties.clientId
output managedIdentityPrincipalId string = managedIdentity.properties.principalId
output managedIdentityTenantId string = managedIdentity.properties.tenantId
