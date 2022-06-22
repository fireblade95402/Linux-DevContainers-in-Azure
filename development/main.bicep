param resourceGroupName string
param location string  

param secretsKeyVault object
param namingConvension object

//parameters for standing of platform
param vnet_object object 
param aci_object object
param dnsresolver_object object
param vpn_object object
param vm_object_array array

//Loads a list of default shared rules for NSG's
var sharedRules = json(loadTextContent('./shared-rules.json')).securityRules

//command to deploy:  az deployment sub create --name dev --location uksouth --template-file main.bicep --parameters main.parameters.json 
//Note: Way to start/stop vm's: https://docs.microsoft.com/en-gb/azure/azure-functions/start-stop-vms/overview

// Setting target scope
targetScope = 'subscription'

// Creating resource group
resource rg 'Microsoft.Resources/resourceGroups@2021-01-01' = {
  name: resourceGroupName
  location: location
}

module naming '../modules/naming.bicep' = {
  name: 'NamingDeployment'
  scope: rg
  params: {
    location: location
    suffix: [
      namingConvension.application
      namingConvension.environment
    ]
    uniqueLength: 6
    uniqueSeed: rg.id
  }
}

//KeyVault to pull secrets from
resource keyVault 'Microsoft.KeyVault/vaults@2019-09-01' existing = {
  name: secretsKeyVault.kvName
  scope: resourceGroup(secretsKeyVault.resourceGroup )
}

//Create NSG's for all non-special subnets
module nsg '../modules/nsg.bicep' = [for subnet in vnet_object.subnets: if (subnet.specialSubnet == false) {
  name: 'nsg-deployment-${subnet.name}'
  scope: rg
  params: {
    location: location
    naming: naming.outputs.names
    suffix: subnet.name
    secRules: concat(subnet.securityRules, sharedRules)
  }
}]

//Create VNET
module vnet '../modules/vnet.bicep' = {
  name: 'vnetdeploy'
  scope: rg
  params: {
    naming: naming.outputs.names
    location: location
    vnet_object: vnet_object
    customdns: []
  }
  dependsOn: [
    nsg
  ]
}

//ACI replaced with PRivate DNS Resolver below
// //Create Azure Container Instance for custom DNS
// module container '../modules/aci.bicep' = {
//   name: 'acideploy'
//   scope: rg
//   params: {
//     location: location
//     naming: naming.outputs.names
//     aci_object: aci_object
//   }
//   dependsOn: [
//     vnet
//   ]
// }

//Create Azure Private DNS Resolver
module dnsresolver '../modules/dnsresolver.bicep' = {
  name: 'dnsresolverdeploy'
  scope: rg
  params: {
    location: location
    naming: naming.outputs.names
    dnsresolver_object: dnsresolver_object
  }
  dependsOn: [
    vnet
  ]
}


//Update VNET with custom DNS Ip Address
module vnetupdate '../modules/vnet.bicep' = {
  name: 'vnetdeployupdate'
  scope: rg
  params: {
    naming: naming.outputs.names
    location: location
    vnet_object: vnet_object
    customdns: [
      dnsresolver.outputs.ipaddress
    ]
  }
  dependsOn: [
    dnsresolver
  ]
}

//Creating VPN Gateway
module vpngateway '../modules/vpngateway.bicep' = {
  name: 'vpndeploy'
  scope: rg
  params: {
    location: location
    naming: naming.outputs.names
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
    naming: naming.outputs.names
    vm_object: vm
    sshkey: keyVault.getSecret(vm.keyVaultSSHKey)
  }
  dependsOn: [
    vnetupdate
  ]
}]





