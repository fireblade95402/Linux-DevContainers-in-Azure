// ------------------------------------------------------------
// networkSecurityGroups -
//  The securityRules object is an array of rules
//   [
//     {
//       name: 'default-allow-rdp'
//       properties: {
//         priority: 1010
//         access: 'Allow'
//         direction: 'Inbound'
//         protocol: 'Tcp'
//         sourcePortRange: '*'
//         sourceAddressPrefix: 'VirtualNetwork'
//         destinationAddressPrefix: '*'
//         destinationPortRange: '3389'
//       }
//     }
//   ]
// See
//  https://docs.microsoft.com/en-us/azure/templates/microsoft.network/networksecuritygroups/securityrules?tabs=json#securityrulepropertiesformat-object
// for more information
// ------------------------------------------------------------
param naming object
param suffix string
param location string = resourceGroup().location
param secRules array
param tags object = {}

targetScope = 'resourceGroup'

resource nsg  'Microsoft.Network/networkSecurityGroups@2020-06-01' = {
  name: suffix != '' ? '${naming.networkSecurityGroup.name}-${suffix}' :  naming.networkSecurityGroup.name
  location: location
  properties: {
    securityRules: secRules
  }
  tags: tags
}

output id string = nsg.id
