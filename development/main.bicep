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
//Note: cool way to start/stop vm's: https://docs.microsoft.com/en-gb/azure/azure-functions/start-stop-vms/overview

// Setting target scope
targetScope = 'subscription'



// Creating resource group
resource rg 'Microsoft.Resources/resourceGroups@2021-01-01' = {
  name: resourceGroupName
  location: location
}

// Naming Convernsion module for all resources being creating
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

//KeyVault to pull secrets from
resource keyVault 'Microsoft.KeyVault/vaults@2019-09-01' existing = {
  name: secretsKeyVault.kvName
  scope: resourceGroup(secretsKeyVault.resourceGroup )
}

//Create VNET
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

//Create Azure Container Instance for custom DNS
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

//Update VNET with custom DNS Ip Address
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

//Creating VPN Gateway
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


//Creating developement VM's
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





