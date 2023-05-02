@minLength(3)
@maxLength(20)
@description('Used to name all resources')
param resourceName string

@allowed([
  'Standard_B1ms' //A very basic VM for light dev work and low hourly compute cost
  'Standard_D4s_v3' //A more powerful VM that supports nested virtualisation but has a higher hourly compute cost
])
param vmSize string = 'Standard_D4s_v3'

param location string = resourceGroup().location

param subnetId string

param adminUsername string = 'azureuser'

param exposeVmToPublicInternet bool
param publicDnsName string = resourceName

@secure()
param sshkey string

var vmName = 'vm-${resourceName}'

var image = {
  publisher: 'Canonical'
  offer: 'UbuntuServer'
  sku: '18.04-LTS'
  version: 'latest'
}

resource publicIPAddress 'Microsoft.Network/publicIPAddresses@2022-09-01' = if(exposeVmToPublicInternet) {
  name: 'pip-${vmName}'
  location: location
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static' //ensures that when VM is stopped we don't lose the IP
    dnsSettings: {
      domainNameLabel: publicDnsName
    }
  }
}


resource nic 'Microsoft.Network/networkInterfaces@2022-09-01' = {
  name: 'nic-${vmName}'
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          publicIPAddress: {
            id: publicIPAddress.id
          }
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: subnetId
          }
        }
      }
    ]
  }
}

resource virtualMachines 'Microsoft.Compute/virtualMachines@2022-11-01' = {
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
      vmSize: vmSize
    }
    storageProfile: {
      imageReference: image
      osDisk: {
          name: 'disk-${vmName}'
          osType: 'Linux'
          createOption: 'FromImage'
          caching: 'ReadWrite'
          managedDisk: {
           storageAccountType: 'Premium_LRS'
          }
          deleteOption: 'Detach'
          diskSizeGB: 30
      }
      dataDisks: []
    }
    osProfile: {
      computerName: take(vmName,8)
      adminUsername: adminUsername
      customData: loadFileAsBase64('../scripts/docker-cloud-init.txt')
      linuxConfiguration: {
        disablePasswordAuthentication: true
        ssh: {
          publicKeys: [
            {
              path: '/home/${adminUsername}/.ssh/authorized_keys'
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

output dnsFqdn string = publicIPAddress.properties.dnsSettings.fqdn
