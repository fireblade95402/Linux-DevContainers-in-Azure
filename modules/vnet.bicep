
// This module creates an Azure VPN with subnets.
// Parameter example
// "vnet_object": {
//   "value": {
//       "addressPrefix": "10.1.0.0/16",
//       "subnets" : [
//         {
//           "name": "customdns",
//           "addressSpace": "10.1.3.0/24",
//           "specialSubnet": false,
//           "securityRules": [],
//           "delegations": [
//             {
//               "name": "delegationService",
//               "properties": {
//                 "serviceName": "Microsoft.ContainerInstance/containerGroups"
//               }
//             }
//           ]
//         }
//       ]
//     }
// }

// customdns : IP Address of the custom DNS server. THis case created in ACI

param location string = resourceGroup().location
param naming object
param vnet_object object
param customdns array
param tags object = {}

targetScope = 'resourceGroup'

resource vnet 'Microsoft.Network/virtualNetworks@2021-02-01' = {
  name: naming.virtualNetwork.name
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
          id: resourceId('Microsoft.Network/networkSecurityGroups', '${naming.networkSecurityGroup.name}-${subnet.name}')
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




