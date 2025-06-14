// StorageAccount.bicep
param storageAccountName string
param location string = resourceGroup().location
param tags object = {}
param storageAccountSku string = 'Standard_LRS'
param storageAccountType string = 'StorageV2'
param containerNames array = []

// Create storage
resource storageAccount 'Microsoft.Storage/storageAccounts@2021-08-01' = {
  name: storageAccountName
  location: location
  tags: tags
  sku: {
    name: storageAccountSku
  }
  kind: storageAccountType
}

resource blobService 'Microsoft.Storage/storageAccounts/blobServices@2021-06-01' = {
  name: '${storageAccount.name}/default'
}

// Create containers if specified
resource containers 'Microsoft.Storage/storageAccounts/blobServices/containers@2021-06-01' = [for containerName in containerNames: {
  parent: blobService
  name: !empty(containerNames) ? '${toLower(containerName)}' : 'placeholder'
  properties: {
    publicAccess: 'None'
    metadata: {}
  }
}]

output name string = storageAccount.name
output accountKey string = listKeys(storageAccount.id, storageAccount.apiVersion).keys[0].value