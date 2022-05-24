param location string = resourceGroup().location
param vnetName string
param vnet_object object
param nsgNameSuffix string
param customdns array

targetScope = 'resourceGroup'

resource vnet 'Microsoft.Network/virtualNetworks@2021-02-01' = {
  name: vnetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        vnet_object.AddressPrefix
      ]
    }
    subnets: [for subnet in vnet_object.subnets: {
      name: subnet.name
      properties: {
        networkSecurityGroup: ((subnet.specialSubnet == false ) ? {
          id: resourceId('Microsoft.Network/networkSecurityGroups', '${subnet.name}-${nsgNameSuffix}')
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




