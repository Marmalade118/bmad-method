param location string = resourceGroup().location

param application string = 'das'

@allowed([
  'dev'
  'uat'
  'prod'
])
param environment string = 'dev' 

param businessUnit string = 'digital'

param additionalTags object = {}
var databaseSku = ((environment == 'dev') ? 'Basic' : 'S0')
var databaseEdition = ((environment == 'dev') ? 'Basic' : 'Standard')
var adminApiSqlDatabaseName = 'sqldb-dosevision-${environment}'
param collation string = 'SQL_Latin1_General_CP1_CI_AS'
param maxSizeBytes string = '1073741824'

var sqlServerName = 'sql-dosevision-${environment}'

resource sqlServer 'Microsoft.Sql/servers@2022-02-01-preview' existing = {
  name: sqlServerName
}

resource sqlServerName_adminApiSqlDatabaseName 'Microsoft.Sql/servers/databases@2014-04-01-preview' = {
  parent: sqlServer
  name: adminApiSqlDatabaseName
  location: location
  tags: union(additionalTags, {
    application: application
    environment: environment
    businessUnit: businessUnit
  })
  properties: {
    edition: databaseEdition
    collation: collation
    maxSizeBytes: maxSizeBytes
    requestedServiceObjectiveName: databaseSku
  }
}



output connectionString string = 'Server=tcp:${sqlServer.properties.fullyQualifiedDomainName};Authentication=Active Directory Default; Database=${adminApiSqlDatabaseName};'
