@minLength(3)
@maxLength(20)
@description('Used to name all resources')
param resourceName string
param location string = resourceGroup().location
param customdns array

resource vnet 'Microsoft.Network/virtualNetworks@2022-09-01' = {
  name: 'vnet-${resourceName}'
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.2.0.0/25'
      ]
    }
    subnets: [
      {
        name: 'GatewaySubnet'
        properties: {
          addressPrefix: '10.2.0.0/29'
        }
      }
      {
        name: 'dnsresolver'
        properties: {
          addressPrefix: '10.2.0.16/28'
          delegations: [
            {
              name: 'delegationService'
              properties: {
                serviceName: 'Microsoft.Network/dnsResolvers'
              }
            }
          ]
        }
      }
      {
        name: 'backend'
        properties: {
          addressPrefix: '10.2.0.32/27'
        }
      }
      {
        name: 'frontend'
        properties: {
          addressPrefix: '10.2.0.64/27'
        }
      }
    ]
    dhcpOptions: {
      dnsServers: customdns
    }
  }
}

output backendSubnetId string = vnet.properties.subnets[2].id
