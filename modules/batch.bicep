param location string
param batchAccountName string
param storageAccountId string

resource batch 'Microsoft.Batch/batchAccounts@2024-02-01' = {
  name: batchAccountName
  location: location
  tags: {
    ObjectName: batchAccountName
  }
  properties: {
    autoStorage: {
      storageAccountId: storageAccountId
    }
  }
}

output batchId string = batch.id
output batchendpoint string = batch.properties.accountEndpoint
