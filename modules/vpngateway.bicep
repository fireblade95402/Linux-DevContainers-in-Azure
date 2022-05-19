
param vpnName string
param location string = resourceGroup().location
param vpn object
param vnetName string 
param pipName string

@secure()
param p2scert string

targetScope = 'resourceGroup'

resource publicIPAddress 'Microsoft.Network/publicIPAddresses@2020-11-01' = {
  name: pipName
  location: location
  sku: {
    name: 'Basic'
    tier: 'Regional'
  }
  properties: {
    publicIPAddressVersion: 'IPv4'
    publicIPAllocationMethod: 'Dynamic'
    idleTimeoutInMinutes: 4
    ipTags: []
  }
}


resource virtualNetworkGateways_dev_gw_name_resource 'Microsoft.Network/virtualNetworkGateways@2020-11-01' = {
  name: vpnName
  location: location
  properties: {
    enablePrivateIpAddress: false
    ipConfigurations: [
      {
        name: 'vnetGatewayConfig0'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: {
            id: publicIPAddress.id
          }
          subnet: {
            id:  resourceId('Microsoft.Network/VirtualNetworks/subnets', vnetName, vpn.subnet)
          }
        }
      }
    ]
    sku: {
      name: vpn.sku
      tier: vpn.sku
    }
    gatewayType: vpn.type
    vpnType: 'RouteBased'
    enableBgp: false
    activeActive: false
    vpnClientConfiguration: {
      vpnClientAddressPool: {
        addressPrefixes: [
          vpn.addressPrefix
        ]
      }
      vpnClientProtocols: [
        'SSTP'
      ]
      vpnAuthenticationTypes: [
        'Certificate'
      ]
      vpnClientRootCertificates: [
        {
          name: 'p2sroot'
          properties: {
            publicCertData: p2scert
          }
        }
      ]
      vpnClientRevokedCertificates: []
      radiusServers: []
      vpnClientIpsecPolicies: []
    }
    vpnGatewayGeneration: vpn.generation
  }
}
