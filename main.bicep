targetScope = 'subscription'

@description('The name of the resource group to create.')
param resourceGroupName string

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

var location = deployment().location

resource resourceGroup 'Microsoft.Resources/resourceGroups@2025-04-01' = {
  name: resourceGroupName
  location: location
}

module storage 'modules/storage.bicep' = {
  name: 'storage'
  scope: resourceGroup
  params: {
    storageAccountName: storageAccountName
    containerName: containerName
    allowSharedKeyAccess: allowSharedKeyAccess
    ipRules: ipRules
    principalIds: principalIds
  }
}
