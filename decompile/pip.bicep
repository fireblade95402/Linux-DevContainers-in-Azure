param publicIPAddresses_dev_gw_pip_name string = 'dev-gw-pip'

resource publicIPAddresses_dev_gw_pip_name_resource 'Microsoft.Network/publicIPAddresses@2020-11-01' = {
  name: publicIPAddresses_dev_gw_pip_name
  location: 'uksouth'
  sku: {
    name: 'Basic'
    tier: 'Regional'
  }
  properties: {
    ipAddress: '51.145.50.114'
    publicIPAddressVersion: 'IPv4'
    publicIPAllocationMethod: 'Dynamic'
    idleTimeoutInMinutes: 4
    ipTags: []
  }
}