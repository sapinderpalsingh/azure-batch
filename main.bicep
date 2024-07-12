targetScope = 'subscription'

param resourceGroupName string = 'sap-bicep-rg'
@description('Location for all resources.')
param location string = 'eastus'

@description('Batch Account Name')
param batchAccountName string = 'sapbatchama'
param storageAccountName string = 'sapbatchamasa'
param poolName string = 'sapbatchpool'
param uamiName string = 'sapbatchuami'

@description('Storage Account type')
@allowed([
  'Standard_LRS'
  'Standard_GRS'
  'Standard_ZRS'
  'Premium_LRS'
])
param storageAccountsku string = 'Standard_LRS'





// Organize resources in a resource group
resource resourceGroup 'Microsoft.Resources/resourceGroups@2023-07-01' = {
  name: resourceGroupName
  location: location  
}

module uami './modules/uami.bicep' = {
  name: 'uami'
  scope: resourceGroup
  params: {
    location: location
    uamiName: uamiName
  }
}

module storage './modules/storage.bicep' = {
  name: 'storage'
  scope: resourceGroup
  params: {
    location: location
    storageAccountsku: storageAccountsku
    storageAccountName: storageAccountName
  }
}

module batch './modules/batch.bicep' = {
  name: 'batch'
  scope: resourceGroup
  dependsOn:[storage, uami]
  params: {
    location: location
    batchAccountName: batchAccountName
    storageAccountId: storage.outputs.storageID
  }
}

module batchpool './modules/batchpool.bicep' = {
  name: 'batchpool'
  scope: resourceGroup
  dependsOn:[batch]
  params: {
    batchName: batchAccountName
    poolName: poolName
    uamiId: uami.outputs.uamiId
    uamiClientId: uami.outputs.uamiClientId
    uamiPrincipalId: uami.outputs.uamiPrincipalId
  }
}

output storageAccountName string = storage.outputs.storageName
output batchId string = batch.outputs.batchId
output batchendpoint string = batch.outputs.batchendpoint
