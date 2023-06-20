param nameseed string = ''
param location string = resourceGroup().location

//parameters for standing of platform
param vnet_object object 
param dnsresolver_object object = {}
param aci_object object = {}
param vpn_object object
param vm_object_array array

//KeyVault to pull secrets from
resource keyVault 'Microsoft.KeyVault/vaults@2019-09-01' existing = {
  name: KeyVault.kvName
  scope: resourceGroup(KeyVault.resourceGroup )
}

//Create NSG's for all non-special subnets

//Create VNET
module vnet '../modules/vnet.bicep' = {
  name: 'vnetdeploy'
  params: {
    location: location
    vnet_object: vnet_object
    customdns: []
  }
}

//Create Azure Private DNS Resolver
module dnsresolver '../modules/dnsresolver.bicep' = if (dnsresolver_object != {}) {
  name: 'dnsresolverdeploy'
  params: {
    location: location
    dnsresolver_object: dnsresolver_object
  }
}

//Create Azure Container Instance for custom DNS
module container '../modules/aci.bicep' =  if (aci_object != {}) {
  name: '${deployment().name}-aci'
  params: {
    location: location
    aci_object: aci_object
  }
}


//Update VNET with custom DNS Ip Address
module vnetupdate '../modules/vnet.bicep' = {
  name: 'vnetdeployupdate'
  scope: rg
  params: {
    location: location
    vnet_object: vnet_object
    customdns: [
      dnsresolver_object != {} ? dnsresolver.outputs.ipaddress : container.outputs.ipaddress
    ]
  }
  dependsOn: [
    dnsresolver
  ]
}

//Creating VPN Gateway
module vpngateway '../modules/vpngateway.bicep' = {
  name: 'vpndeploy'
  params: {
    location: location
    vpn: vpn_object
    p2scert: keyVault.getSecret(vpn_object.keyVaultP2SCert)
  }
}


//Creating  VM
module virtualMachines '../modules/vm.bicep' = [for vm in vm_object_array :{
  name: '${vm.name}-vmdeploy'
  params: {
    location: location
    vm_object: vm
    sshkey: keyVault.getSecret(vm.keyVaultSSHKey)
  }
}]
