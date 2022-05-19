
param location string
param vm object
param vnetName string

@secure()
param sshkey string

resource nic 'Microsoft.Network/networkInterfaces@2021-02-01' = {
  name: '${vm.name}-nic'
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAllocationMethod: 'Static'
          subnet: {
            id: resourceId('Microsoft.Network/virtualNetworks/subnets', vnetName, vm.subnet)
          }
        }
      }
    ]
  }
}

resource virtualMachines 'Microsoft.Compute/virtualMachines@2021-11-01' = {
  name: vm.name
  location: location
  tags: {
    enabled: 'true'
  }
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    hardwareProfile: {
      vmSize: vm.vmSize
    }
    storageProfile: {
      imageReference: vm.imageReference
      osDisk: {}
      dataDisks: []
    }
    osProfile: {
      computerName: vm.name
      adminUsername: vm.adminUsername
      linuxConfiguration: {
        disablePasswordAuthentication: true
        ssh: {
          publicKeys: [
            {
              path: '/home/${vm.adminUsername}/.ssh/authorized_keys'
              keyData: sshkey
            }
          ]
        }
        provisionVMAgent: true
        patchSettings: {
          patchMode: 'ImageDefault'
          assessmentMode: 'ImageDefault'
        }
      }
      secrets: []
      allowExtensionOperations: true
      requireGuestProvisionSignal: true
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: nic.id
          properties: {
            primary: true
          }
        }
      ]
    }
  }
}


