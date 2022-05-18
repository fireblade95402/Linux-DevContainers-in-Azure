
param location string = resourceGroup().location
param aciName string 
param aci object
param vnetName string

targetScope = 'resourceGroup'


resource containerGroup 'Microsoft.ContainerInstance/containerGroups@2021-09-01' = {
  name: aciName
  location: location
  properties: {
    containers: [
      {
        name: aciName
        properties: {
          command: [
            aci.commandline
          ]
          image: aci.image
          ports: [
            {
              port: aci.port
              protocol: aci.protocol
            }
          ]
          resources: {
            requests: {
              cpu: aci.cpuCores
              memoryInGB: aci.memoryInGb
            }
          }
          volumeMounts: [
            {
            name: 'gitrepo'
            mountPath: aci.gitrepomountpath
            }
          ]
        }
      }
    ]
    osType: 'Linux'
    restartPolicy: aci.restartPolicy
    subnetIds: [
      {
        id: resourceId('Microsoft.Network/VirtualNetworks/subnets', vnetName, aci.subnet)
      }
    ]
    ipAddress: {
      type: 'Private'
      ports: [
        {
          port: aci.port
          protocol: aci.protocol
        }
      ]
    }
    volumes: [
      {
        name: 'gitrepo'
        gitRepo: {
          directory: '.'
          repository: aci.gitrepourl
        }
      }
    ]
  }
}


