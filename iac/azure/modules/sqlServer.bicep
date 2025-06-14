param location string = resourceGroup().location
@allowed([
  'dev'
  'uat'
  'prod'
])
param environment string = 'dev' 

var sqlServerName = 'sql-dosevision-${environment}'

resource sqlServer 'Microsoft.Sql/servers@2022-02-01-preview' = {
  location: location
  name: sqlServerName
  properties: {
    administrators: {
      administratorType: 'ActiveDirectory'
      principalType: 'group'
      login: 'rob.marwood@tracerco.com'
      sid: 'c2da0659-a663-4a42-8aaf-a758432f2315'
      tenantId: subscription().tenantId
      azureADOnlyAuthentication: true
    }
  }
}

output name string = sqlServerName
