
param location string
param vmName string
param nicName string
param vm object
param vnetName string
param osDiskName string

@secure()
param sshkey string

resource nic 'Microsoft.Network/networkInterfaces@2021-02-01' = {
  name: nicName
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAllocationMethod: 'Static'
          privateIPAddress: vm.ipaddress
          subnet: {
            id: resourceId('Microsoft.Network/virtualNetworks/subnets', vnetName, vm.subnet)
          }
        }
      }
    ]
  }
}

resource virtualMachines 'Microsoft.Compute/virtualMachines@2021-11-01' = {
  name: vmName
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
      osDisk: {
          name: osDiskName
          osType: vm.osDisk.osType
          createOption:vm.osDisk.createOption
          caching: vm.osDisk.caching
          managedDisk: {
           storageAccountType:vm.osDisk.managedDisk.storageAccountType
          }
          deleteOption: vm.osDisk.deleteOption
          diskSizeGB: vm.osDisk.diskSizeGB
      }
      dataDisks: []
    }
    osProfile: {
      computerName: vmName
      adminUsername: vm.adminUsername
      customData: loadFileAsBase64('../scripts/docker-cloud-init.txt')
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


