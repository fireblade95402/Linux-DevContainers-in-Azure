param resourceGroupName string
param location string  

param secretsKeyVault object
param namingConvension object

//parameters for standing of platform
param vnet_object object 
param aci_object object
param vpn_object object
param vm_object_array array

//Loads a list of default shared rules for NSG's
var sharedRules = json(loadTextContent('./shared-rules.json')).securityRules

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
module names '../modules/namingconvension.bicep' =  {
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

//Default names for resoruces using the namingconversion module
var nsgNameSuffix = replace(names.outputs.resourceName, '[PH]', 'nsg')
var vnetName = replace(names.outputs.resourceName, '[PH]', 'vnet')
var aciName = replace(names.outputs.resourceName, '[PH]', 'aci')
var vpnName = replace(names.outputs.resourceName, '[PH]', 'vpn')
var vpnPipName = replace(names.outputs.resourceName, '[PH]', 'vpn-pip')
var vmNameSuffix =  replace(names.outputs.resourceName, '[PH]', 'vm')
var vmNicNameSuffix =  replace(names.outputs.resourceName, '[PH]', 'vm-nic')
var vmOsDiskNameSuffix =  replace(names.outputs.resourceName, '[PH]', 'vm-osdisk')

//Create NSG's for all non-special subnets
module nsg '../modules/nsg.bicep' = [for subnet in vnet_object.subnets: if (subnet.specialSubnet == false) {
  name: 'nsg-deployment-${subnet.name}'
  scope: rg
  params: {
    location: location
    nsgName: '${subnet.name}-${nsgNameSuffix}'
    secRules: concat(subnet.securityRules, sharedRules)
  }
}]

//Create VNET
module vnet '../modules/vnet.bicep' = {
  name: 'vnetdeploy'
  scope: rg
  params: {
    vnetName: vnetName
    location: location
    vnet_object: vnet_object
    nsgNameSuffix: nsgNameSuffix
    customdns: []
  }
  dependsOn: [
    nsg
  ]
}

//Create Azure Container Instance for custom DNS
module container '../modules/aci.bicep' = {
  name: 'acideploy'
  scope: rg
  params: {
    location: location
    aciName: aciName
    aci: aci_object
    vnetName: vnetName
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
    vnetName: vnetName
    location: location
    vnet_object: vnet_object
    nsgNameSuffix: nsgNameSuffix
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
    vpnName: vpnName
    vnetName: vnetName
    pipName:  vpnPipName
    vpn: vpn_object
    p2scert: keyVault.getSecret(vpn_object.keyVaultP2SCert)
  }
  dependsOn: [
    vnetupdate
  ]
}


//Creating  VM's
module virtualMachines '../modules/vm.bicep' = [for vm in vm_object_array :{
  name: '${vm.name}-vmdeploy'
  scope: rg
  params: {
    location: location
    vmName: '${vm.name}-${vmNameSuffix}'
    nicName: '${vm.name}-${vmNicNameSuffix}'
    osDiskName: '${vm.name}-${vmOsDiskNameSuffix}'
    vm: vm
    sshkey: keyVault.getSecret(vm.keyVaultSSHKey)
    vnetName: vnetName

  }
  dependsOn: [
    vnetupdate
  ]
}]





