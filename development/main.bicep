param resourceGroupName string
param location string  
param secretsKeyVault object
param namingConvension object
param vnetAddressPrefix string
param subNets array
param aci object
param vpn object
param vms array


//command to deploy:  az deployment sub create --name dev --location uksouth --template-file main.bicep --parameters main.parameters.json 
// Setting target scope
targetScope = 'subscription'



// Creating resource group
resource rg 'Microsoft.Resources/resourceGroups@2021-01-01' = {
  name: resourceGroupName
  location: location
}

module names '../modules/namingconvension.bicep' = {
  name: 'namingconvention'
  scope: rg
  params: {
    environment: namingConvension.environment
    function:  namingConvension.function
    index:  namingConvension.index
    teamName:  namingConvension.teamName
  }
}

resource keyVault 'Microsoft.KeyVault/vaults@2019-09-01' existing = {
  name: secretsKeyVault.kvName
  scope: resourceGroup(secretsKeyVault.resourceGroup )
}


module vnet '../modules/vnet.bicep' = {
  name: 'vnetdeploy'
  scope: rg
  params: {
    vnetName: replace(names.outputs.resourceName, '[PH]', 'vnet')
    location: location
    vnetAddressPrefix: vnetAddressPrefix
    subNets: subNets
    nsgName: replace(names.outputs.resourceName, '[PH]', 'nsg')
    customdns: []
  }
}


module container '../modules/aci.bicep' = {
  name: 'acideploy'
  scope: rg
  params: {
    location: location
    aciName: replace(names.outputs.resourceName, '[PH]', 'aci')
    aci: aci
    vnetName: replace(names.outputs.resourceName, '[PH]', 'vnet')
  }
  dependsOn: [
    vnet
  ]
}

module vnetupdate '../modules/vnet.bicep' = {
  name: 'vnetupdatedeploy'
  scope: rg
  params: {
    vnetName: replace(names.outputs.resourceName, '[PH]', 'vnet')
    location: location
    vnetAddressPrefix: vnetAddressPrefix
    subNets: subNets
    nsgName: replace(names.outputs.resourceName, '[PH]', 'nsg')
    customdns: [
      container.outputs.ipaddress
    ]
  }
  dependsOn: [
    container
  ]
}

module vpngateway '../modules/vpngateway.bicep' = {
  name: 'vpndeploy'
  scope: rg
  params: {
    location: location
    vpnName: replace(names.outputs.resourceName, '[PH]', 'vpn')
    vnetName: replace(names.outputs.resourceName, '[PH]', 'vnet')
    pipName:  replace(names.outputs.resourceName, '[PH]', 'vpn-pip')
    vpn: vpn
    p2scert: keyVault.getSecret(vpn.keyVaultP2SCert)
  }
  dependsOn: [
    vnetupdate
  ]
}



module virtualMachines '../modules/vm.bicep' = [for vm in vms :{
  name: '${vm.name}-vmdeploy'
  scope: rg
  params: {
    location: location
    vmName: '${vm.name}-${replace(names.outputs.resourceName, '[PH]', 'vm')}'
    nicName: '${vm.name}-${replace(names.outputs.resourceName, '[PH]', 'vm-nic')}'
    osDiskName: '${vm.name}-${replace(names.outputs.resourceName, '[PH]', 'vm-osdisk')}'
    vm: vm
    sshkey: keyVault.getSecret(vm.keyVaultSSHKey)
    vnetName: replace(names.outputs.resourceName, '[PH]', 'vnet')

  }
  dependsOn: [
    vnetupdate
  ]
}]





