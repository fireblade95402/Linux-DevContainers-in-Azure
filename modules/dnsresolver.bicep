param location string = resourceGroup().location
param naming object
param dnsresolver_object object
param tags object = {}

targetScope = 'resourceGroup'


resource virtualNetwork 'Microsoft.Network/virtualNetworks@2021-05-01' existing = {
  name: naming.virtualNetwork.name
}

resource subnet 'Microsoft.Network/virtualNetworks/subnets@2022-01-01'  existing = {
  name: dnsresolver_object.subnet
  parent: virtualNetwork
}


resource dnsResolvers_dnsresolver_name_resource 'Microsoft.Network/dnsResolvers@2020-04-01-preview' = {
  name: naming.privatednsresolver.name
  location: location
  properties: {
    virtualNetwork: {
      id: virtualNetwork.id
    }
  }
}

resource dnsResolvers_dnsresolver_name_inboundendpoint 'Microsoft.Network/dnsResolvers/inboundEndpoints@2020-04-01-preview' = {
  parent: dnsResolvers_dnsresolver_name_resource
  name: 'inboundendpoint'
  location: location
  properties: {
    ipConfigurations: [
      {
        subnet: {
          id: subnet.id
        }
        privateIpAllocationMethod: 'Dynamic'
      }
    ]
  }
}

output ipaddress string = dnsResolvers_dnsresolver_name_inboundendpoint.properties.ipConfigurations[0].privateIpAddress

