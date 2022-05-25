
// This module creates an Azure VPN Gateway.
// Currently used for creating  the VPN to securely connect to the VNET and VM's.
// Parameter example
// "vpn_object": {
//   "value": {
//     "sku": "Basic",
//     "type": "Vpn",
//     "addressPrefix": "172.16.24.0/24",
//     "subnet": "GatewaySubnet",
//     "generation": "Generation1",
//     "keyVaultP2SCert": "p2sroot"
//   }
// }

// vpmName : Name of VPN Resource to be created
// vnetname : Name of vnet to link too via a subnet
// pipName : Public IP Address Name for created resource


param location string = resourceGroup().location
param naming object
param vpn object

@secure()
param p2scert string

targetScope = 'resourceGroup'



resource publicIPAddress 'Microsoft.Network/publicIPAddresses@2020-11-01' = {
  name: '${naming.publicIp.name}-${naming.virtualNetworkGateway.slug}'
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
  name: naming.virtualNetworkGateway.name
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
            id:  resourceId('Microsoft.Network/VirtualNetworks/subnets', naming.virtualNetwork.name, vpn.subnet)
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
