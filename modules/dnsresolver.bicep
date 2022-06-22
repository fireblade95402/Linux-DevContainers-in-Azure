param location string = resourceGroup().location
param naming object
param dnsresolver_object object
param tags object = {}

targetScope = 'resourceGroup'


param virtualNetworks_vnet_externalid string = resourceId('Microsoft.Network/virtualNetworks',  naming.virtualNetwork.name) 

resource dnsResolvers_dnsresolver_name_resource 'Microsoft.Network/dnsResolvers@2020-04-01-preview' = {
  name: naming.privatednsresolver.name
  location: location
  properties: {
    virtualNetwork: {
      id: virtualNetworks_vnet_externalid
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
          id: '${virtualNetworks_vnet_externalid}/subnets/${dnsresolver_object.subnet}'
        }
        privateIpAllocationMethod: 'Dynamic'
      }
    ]
  }
}

output ipaddress string = dnsResolvers_dnsresolver_name_inboundendpoint.properties.ipConfigurations[0].privateIpAddress

