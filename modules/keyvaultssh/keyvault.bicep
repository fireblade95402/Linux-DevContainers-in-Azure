@minLength(3)
@maxLength(20)
@description('Used to name all resources')
param resourceName string

param location string = resourceGroup().location
param createRbacForDeployingUser bool = true
param deployingUserPrincipalId string = ''
param logAnalyticsWorkspaceId string = ''

var akvName = take('kv-${replace(resourceName, '-', '')}${uniqueString(resourceGroup().id, resourceName)}',24)

var keyVaultSecretsUserRole = subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '4633458b-17de-408a-b874-0445c86b69e6')

resource roleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = if(createRbacForDeployingUser && !empty(deployingUserPrincipalId)) {
  name: guid(keyVault.id, keyVaultSecretsUserRole, deployingUserPrincipalId)
  scope: keyVault
  properties: {
    roleDefinitionId: keyVaultSecretsUserRole
    principalId: deployingUserPrincipalId
    principalType: 'User'
  }
}

resource keyVault 'Microsoft.KeyVault/vaults@2022-11-01' = {
  name: akvName
  location: location
  properties: {
    tenantId: subscription().tenantId
    sku: {
      name: 'standard'
      family: 'A'
    }
    enableRbacAuthorization: true
    enabledForDeployment: false //VM
    enabledForDiskEncryption: false
    enabledForTemplateDeployment: true //ARM
  }
}

resource kvDiags 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if (!empty(logAnalyticsWorkspaceId)) {
  name: 'kvDiags'
  scope: keyVault
  properties: {
    workspaceId: logAnalyticsWorkspaceId
    logs: [
      {
        category: 'AuditEvent'
        enabled: true
      }
    ]
    metrics: [
      {
        category: 'AllMetrics'
        enabled: true
      }
    ]
  }
}

output keyVaultName string = keyVault.name
output keyVaultId string = keyVault.id
