@description('The name of the Storage account to create.')
param storageAccountName string

@description('The name of the blob container to create.')
param containerName string = 'tfstate'

@description('Allow authenticating to the storage account using a shared access key?')
param allowSharedKeyAccess bool = false

@description('An array of IP addresses or IP ranges that should be allowed to bypass the firewall of the Terraform backend. If empty, the firewall will be disabled.')
param ipRules array = []

@description('An array of object IDs of user, group or service principals that should have access to the Terraform backend.')
param principalIds array = []

resource storageAccount 'Microsoft.Storage/storageAccounts@2023-05-01' = {
  name: storageAccountName
  location: resourceGroup().location
  sku: {
    name: 'Standard_GRS'
  }
  kind: 'StorageV2'
  properties: {
    accessTier: 'Hot'
    supportsHttpsTrafficOnly: true
    minimumTlsVersion: 'TLS1_2'
    allowBlobPublicAccess: false
    allowSharedKeyAccess: allowSharedKeyAccess
    allowCrossTenantReplication: false
    networkAcls: {
      defaultAction: length(ipRules) == 0 ? 'Allow' : 'Deny'
      virtualNetworkRules: []
      ipRules: [
        for ipRule in ipRules: {
          value: ipRule
          action: 'Allow'
        }
      ]
    }
  }

  resource blobService 'blobServices' = {
    name: 'default'
    properties: {
      deleteRetentionPolicy: {
        allowPermanentDelete: false
        enabled: true
        days: 30
      }
      containerDeleteRetentionPolicy: {
        enabled: true
        days: 30
      }
      isVersioningEnabled: true
      changeFeed: {
        enabled: true
      }
    }

    resource container 'containers' = {
      name: containerName
    }
  }

  resource managementPolicy 'managementPolicies' = {
    name: 'default'
    properties: {
      policy: {
        rules: [
          {
            name: 'Delete old tfstate versions'
            enabled: true
            type: 'Lifecycle'
            definition: {
              actions: {
                version: {
                  delete: {
                    daysAfterCreationGreaterThan: 30
                  }
                }
              }
              filters: {
                blobTypes: [
                  'blockBlob'
                ]
              }
            }
          }
        ]
      }
    }
  }
}

resource roleDefinition 'Microsoft.Authorization/roleDefinitions@2022-05-01-preview' existing = {
  name: 'b7e6dc6d-f1e8-4753-8033-0f276bb0955b' // Storage Blob Data Owner
  scope: subscription()
}

resource roleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = [
  for principalId in principalIds: {
    name: guid(storageAccount::blobService::container.id, principalId, roleDefinition.id)
    scope: storageAccount::blobService::container
    properties: {
      principalId: principalId
      roleDefinitionId: roleDefinition.id
    }
  }
]

resource lock 'Microsoft.Authorization/locks@2020-05-01' = {
  name: 'Terraform'
  scope: storageAccount
  dependsOn: [storageAccount::blobService, storageAccount::managementPolicy, roleAssignment] // Lock must be created last
  properties: {
    level: 'ReadOnly'
    notes: 'Prevent changes to Terraform backend configuration'
  }
}

@description('The name of the Storage account that was created.')
output storageAccountName string = storageAccount.name

@description('The name of the blob container that was created.')
output containerName string = storageAccount::blobService::container.name
