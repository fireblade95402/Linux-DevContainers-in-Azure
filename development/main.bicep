param resourceGroup string
param location string  
param defaultPrefix string
param vnetAddressPrefix string
param subNets array
param aci object
param vpn object


//variables
var vnetName = '${defaultPrefix}-vnet'
var nsgName = '${defaultPrefix}-nsg'
var aciName = '${defaultPrefix}-aci'
var vpnName = '${defaultPrefix}-vpn'


//command to deploy:  az deployment sub create --name dev --location uksouth --template-file main.bicep --parameters main.parameters.json 
// Setting target scope
targetScope = 'subscription'

// Creating resource group
resource rg 'Microsoft.Resources/resourceGroups@2021-01-01' = {
  name: resourceGroup
  location: location
}


module vnet '../modules/vnet.bicep' = {
  name: 'vnetdeploy'
  scope: rg
  params: {
    vnetName: vnetName
    location: location
    vnetAddressPrefix: vnetAddressPrefix
    subNets: subNets
    nsgName: nsgName
  }
}


module container '../modules/aci.bicep' = {
  name: 'acideploy'
  scope: rg
  params: {
    location: location
    aciName: aciName
    aci: aci
    vnetName: vnetName
  }
  dependsOn: [
    vnet
  ]
}

module vpngateway '../modules/vpngateway.bicep' = {
  name: 'vpndeploy'
  scope: rg
  params: {
    location: location
    vpnName: vpnName
    vpn: vpn
  }

}





