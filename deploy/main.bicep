@minLength(3)
@maxLength(20)
@description('Used to name all resources')
param resourceName string

param location string = resourceGroup().location

param deployingUserPrincipalId string

@allowed([
  'publicIpOnVm'
])
param exposureModel string = 'publicIpOnVm'

module vnet '../modules/vnet.bicep' = {
  name: '${deployment().name}-vnet'
  params: {
    resourceName: resourceName
    location: location
    customdns: []
  }
}

module keyvault '../modules/keyvaultssh/keyvault.bicep' = {
  name: '${deployment().name}-keyvault'
  params: {
    resourceName: resourceName
    location: location
    createRbacForDeployingUser: true
    deployingUserPrincipalId: deployingUserPrincipalId
    logAnalyticsWorkspaceId: '' //No logging right now.
  }
}

module kvSshSecret '../modules/keyvaultssh/ssh.bicep' = {
  name: '${deployment().name}-kvsshsecret'
  params: {
    akvName: keyvault.outputs.keyVaultName
    location: location
    sshKeyName: 'vmSsh'
  }
}

@description('Key Vault reference to the SSH public key secret. Used to pass the public key to the VM module.')
resource kvRef 'Microsoft.KeyVault/vaults@2022-11-01' existing = {
  name: keyvault.outputs.keyVaultName
}

@description('''
Creates the VM - this module is not idempotent, so it will fail if the VM already exists. To update the VM, delete it first.
eg. "Changing property 'linuxConfiguration.ssh.publicKeys' is not allowed."
''')
module vm '../modules/vm.bicep' = {
  name: '${deployment().name}-vm'
  params: {
    resourceName: resourceName
    location: location
    exposeVmToPublicInternet: exposureModel=='publicIpOnVm'
    sshkey: kvRef.getSecret(kvSshSecret.outputs.publicKeySecretName)
    subnetId: vnet.outputs.backendSubnetId
  }
}

output keyVaultName string = keyvault.outputs.keyVaultName
