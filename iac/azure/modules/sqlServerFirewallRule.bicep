param sqlName string

resource sqlServer 'Microsoft.Sql/servers@2022-02-01-preview' existing = {
  name: sqlName
} 

resource sqlServerName_AllowAllWindowsAzureIps 'Microsoft.Sql/servers/firewallRules@2022-05-01-preview' = {
  parent: sqlServer
  name: 'AllowAllWindowsAzureIps'
  properties: {
    endIpAddress: '0.0.0.0' 
    startIpAddress: '0.0.0.0'
  }
}
