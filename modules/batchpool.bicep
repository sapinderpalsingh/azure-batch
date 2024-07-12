param batchName string
param poolName string
param uamiId string
param uamiClientId string
param uamiPrincipalId string

@description('Name of the VM SKU used by the Batch pool')
param vmSize string = 'Standard_D1_v2'

resource batch 'Microsoft.Batch/batchAccounts@2024-02-01' existing = {
  name: batchName
}

resource batchPool 'Microsoft.Batch/batchAccounts/pools@2022-10-01' = {
  name: poolName
  parent: batch
  
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${uamiId}': {}
    }
  }
  properties: {
    vmSize: vmSize
    targetNodeCommunicationMode: 'Simplified'
    interNodeCommunication: 'Disabled'
    taskSlotsPerNode: 4
    taskSchedulingPolicy: {
      nodeFillType: 'Pack'
    }
    deploymentConfiguration: {
      virtualMachineConfiguration: {
        imageReference: {
          publisher: 'canonical'
          offer: 'ubuntuserver'
          sku: '18.04-lts'
          version: 'latest'
        }
        nodeAgentSkuId: 'batch.node.ubuntu 18.04'
        extensions:[
          {
            name: 'AzureMonitorAgentLinux'
            publisher: 'Microsoft.Azure.Monitor'
            type: 'AzureMonitorLinuxAgent'
            typeHandlerVersion: '1.3'
            
            autoUpgradeMinorVersion: true
            settings:{
              enableAMA: true
              authentication: {
                managedIdentity: {
                  'identifier-name': 'client_id'
                  'identifier-value': uamiClientId
                }
              }                            
            }
          }
        ]
      }
    }
    // networkConfiguration: {
    //   subnetId: vnet::subnet.id
    //   publicIPAddressConfiguration: {
    //     provision: 'NoPublicIPAddresses'
    //   }
    // }
    scaleSettings: {
      fixedScale: {
        targetDedicatedNodes: 1
        targetLowPriorityNodes: 0
        resizeTimeout: 'PT15M'
      }
    }
  }
}
