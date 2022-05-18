
param vpnName string
param location string = resourceGroup().location
param vpn object

targetScope = 'resourceGroup'

resource vpnGateway 'Microsoft.Network/vpnGateways@2021-08-01' = {
  name: vpnName
  location: location
  properties: {
      
  }

}
