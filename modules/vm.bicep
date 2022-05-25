
// This module creates an Azure Virtual MAchines for vscode development.
// Parameter example
// "vm_object_array": {
//   "value": [
//     {
//       "name": "dev",
//       "adminUsername": "azureuser",
//       "vmSize": "Standard_DS1_v2",
//       "keyVaultSSHKey": "sshkey",
//       "subnet": "backend",
//       "ipaddress": "10.1.2.5",
//       "imageReference": {
//         "publisher": "Canonical",
//         "offer": "UbuntuServer",
//         "sku": "18.04-LTS",
//         "version": "latest"
//       },
//       "osDisk": {
//         "osType": "Linux",
//         "createOption": "FromImage",
//         "caching": "ReadWrite",
//         "managedDisk": {
//           "storageAccountType": "Premium_LRS"
//         },
//         "deleteOption": "Detach",
//         "diskSizeGB": 30
//       }
//     }
//   ]
// }

// vmName : Name of the VM
// nicNAme : Name of the NIC to be created
// vnetName : Name of vnet to link too via a subnet
// osDiskName : Name of the OS Disk to create

param location string
param vm_object object
param naming object

@secure()
param sshkey string

resource nic 'Microsoft.Network/networkInterfaces@2021-02-01' = {
  name: '${naming.networkInterface.name}-${naming.virtualMachine.slug}-${vm_object.name}'
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAllocationMethod: 'Static'
          privateIPAddress: vm_object.ipaddress
          subnet: {
            id: resourceId('Microsoft.Network/virtualNetworks/subnets', naming.virtualNetwork.name, vm_object.subnet)
          }
        }
      }
    ]
  }
}

resource virtualMachines 'Microsoft.Compute/virtualMachines@2021-11-01' = {
  name: '${naming.virtualMachine.name}-${vm_object.name}'
  location: location
  tags: {
    enabled: 'true'
  }
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    hardwareProfile: {
      vmSize: vm_object.vmSize
    }
    storageProfile: {
      imageReference: vm_object.imageReference
      osDisk: {
          name: '${naming.managedDisk.name}-${vm_object.name}'
          osType: vm_object.osDisk.osType
          createOption:vm_object.osDisk.createOption
          caching: vm_object.osDisk.caching
          managedDisk: {
           storageAccountType:vm_object.osDisk.managedDisk.storageAccountType
          }
          deleteOption: vm_object.osDisk.deleteOption
          diskSizeGB: vm_object.osDisk.diskSizeGB
      }
      dataDisks: []
    }
    osProfile: {
      computerName: '${naming.virtualMachine.name}-${vm_object.name}'
      adminUsername: vm_object.adminUsername
      customData: loadFileAsBase64('../scripts/docker-cloud-init.txt')
      linuxConfiguration: {
        disablePasswordAuthentication: true
        ssh: {
          publicKeys: [
            {
              path: '/home/${vm_object.adminUsername}/.ssh/authorized_keys'
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


