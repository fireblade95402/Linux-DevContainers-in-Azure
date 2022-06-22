param dnsResolvers_dnsresolver_name string = 'dnsresolver'
param virtualNetworks_vnet_vscode_prod_externalid string = '/subscriptions/461377a7-433d-4980-9506-c35defb10a49/resourceGroups/myvscode/providers/Microsoft.Network/virtualNetworks/vnet-vscode-prod'

resource dnsResolvers_dnsresolver_name_resource 'Microsoft.Network/dnsResolvers@2020-04-01-preview' = {
  name: dnsResolvers_dnsresolver_name
  location: 'uksouth'
  properties: {
    virtualNetwork: {
      id: virtualNetworks_vnet_vscode_prod_externalid
    }
  }
}

resource dnsResolvers_dnsresolver_name_inboundendpoint 'Microsoft.Network/dnsResolvers/inboundEndpoints@2020-04-01-preview' = {
  parent: dnsResolvers_dnsresolver_name_resource
  name: 'inboundendpoint'
  location: 'uksouth'
  properties: {
    ipConfigurations: [
      {
        subnet: {
          id: '${virtualNetworks_vnet_vscode_prod_externalid}/subnets/dnsresolver'
        }
        privateIpAddress: '10.2.0.20'
        privateIpAllocationMethod: 'Dynamic'
      }
    ]
  }
}