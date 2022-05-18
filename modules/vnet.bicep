param location string = resourceGroup().location
param vnetName string
param vnetAddressPrefix string
param subNets array
param nsgName string

targetScope = 'resourceGroup'

resource vnet 'Microsoft.Network/virtualNetworks@2021-02-01' = {
  name: vnetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        vnetAddressPrefix
      ]
    }
    subnets: [for subnet in subNets: {
      name: subnet.name
      properties: {
        addressPrefix: subnet.addressSpace
        delegations: subnet.delegations
      }
    }]
  }
}

module nsg '../modules/nsg.bicep' = [for subnet in subNets: if (subnet.securityRules != []) {
  name: 'nsg-deployment-${subnet.name}'
  scope: resourceGroup()
  params: {
    location: location
    nsgName: '${subnet.name}-${nsgName}'
    secRules: subnet.securityRules
  }
}]


