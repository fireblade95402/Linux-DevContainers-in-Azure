param virtualMachines_dev2_vm_name string = 'dev2-vm'
param disks_dev2_vm_OsDisk_1_0ee791d9de0d48c480a4a29dc7620ea1_externalid string = '/subscriptions/461377a7-433d-4980-9506-c35defb10a49/resourceGroups/DEVELOPMENT/providers/Microsoft.Compute/disks/dev2-vm_OsDisk_1_0ee791d9de0d48c480a4a29dc7620ea1'
param networkInterfaces_dev2_nic_externalid string = '/subscriptions/461377a7-433d-4980-9506-c35defb10a49/resourceGroups/development/providers/Microsoft.Network/networkInterfaces/dev2-nic'

resource virtualMachines_dev2_vm_name_resource 'Microsoft.Compute/virtualMachines@2021-11-01' = {
  name: virtualMachines_dev2_vm_name
  location: 'uksouth'
  tags: {
    enabled: 'true'
  }
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    hardwareProfile: {
      vmSize: 'Standard_DS1_v2'
    }
    storageProfile: {
      imageReference: {
        publisher: 'Canonical'
        offer: 'UbuntuServer'
        sku: '18.04-LTS'
        version: 'latest'
      }
      osDisk: {
        osType: 'Linux'
        name: '${virtualMachines_dev2_vm_name}_OsDisk_1_0ee791d9de0d48c480a4a29dc7620ea1'
        createOption: 'FromImage'
        caching: 'ReadWrite'
        managedDisk: {
          storageAccountType: 'Premium_LRS'
          id: disks_dev2_vm_OsDisk_1_0ee791d9de0d48c480a4a29dc7620ea1_externalid
        }
        deleteOption: 'Detach'
        diskSizeGB: 30
      }
      dataDisks: []
    }
    osProfile: {
      computerName: virtualMachines_dev2_vm_name
      adminUsername: 'azureuser'
      linuxConfiguration: {
        disablePasswordAuthentication: true
        ssh: {
          publicKeys: [
            {
              path: '/home/azureuser/.ssh/authorized_keys'
              keyData: 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC6ZgLqM4lBxKtr6GfEWecT4jN4R8zjdY5KgWqrmCwmuUhMqoVRf17KGQe418sNrMXy7Jj6mOP4RdxmKNu3H6L1BaeO0Onq4dJvv232oJMN6CFWhxDE+DmIwrs15nZE5QvVtVDadsyFzAxsCqc4yrBUenjnNFIgP04Jj8pdeL0OlRq7wLi3AsqhG62UL8R5uhmuZp38BVBlGwjtHCJhlCaQvV1gHa0TmVbGbXQ/SSHCd3qCcR6LJI30XrSzuBcLOHupfjoVxWXOEBmlSLpeG+fjKn3B7W/Jlo+GyfG8TYojuLlEQ4thb6KVzYW42rFZHZN/1bngUTV9fxAEMx9FVh8/e9uESSlJLqb8uOBd6ZcYS1N3keY03RSSFTtIfTb1Zxj0cT3qlEcQb7Hc8GDkP4e6wPpNKIb7FF+UeuXegShbX+nb4WUgh8k4BvI9bKsh38HYcsUBlHvb9dpbrd52N0ej2SZ2zuMVpR7Jlw/2VW5Pry4bvAMvoKoXbkm0V6G2Prk= europe\\magraham@Mark-Work\n'
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
          id: networkInterfaces_dev2_nic_externalid
          properties: {
            primary: true
          }
        }
      ]
    }
  }
}