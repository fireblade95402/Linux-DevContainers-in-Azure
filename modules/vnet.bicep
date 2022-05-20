param location string = resourceGroup().location
param vnetName string
param vnetAddressPrefix string
param subNets array
param nsgName string
param customdns array

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
        networkSecurityGroup: ((subnet.specialSubnet == false ) ? {
          id: resourceId('Microsoft.Network/networkSecurityGroups', '${subnet.name}-${nsgName}')
        } : null)
        
        addressPrefix: subnet.addressSpace
        delegations: subnet.delegations
      }
    }]
    dhcpOptions: {
      dnsServers: customdns
    }
  }
}




