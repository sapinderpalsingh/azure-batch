param location string
param storageAccountsku string
param storageAccountName string

// Create a storage account
resource storage 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name: storageAccountName
  location: location
  sku: {
    name: storageAccountsku
  }
  kind: 'StorageV2'
  tags: {
    ObjectName: storageAccountName
  }
  properties: {
    minimumTlsVersion: 'TLS1_2'
    allowBlobPublicAccess: false
    networkAcls: {
      defaultAction: 'Deny'
    }
    supportsHttpsTrafficOnly: true
  }
}

output storageID string = storage.id
output storageName string = storage.name
