
  // This module creates an Azure COntainer Instance.
  // Currently used for creating  custome dns service for the VNET.
  // Parameter example
  // "aci_object": {
  //   "value": {
  //     "image": "coredns/coredns:latest",
  //     "port": 53,
  //     "cpuCores": 1,
  //     "memoryInGb": 0.5,
  //     "protocol": "UDP",
  //     "restartPolicy": "Always",
  //     "gitrepourl": "https://github.com/fireblade95402/bicep",
  //     "gitrepomountpath": "/config",
  //     "commandline": [
  //       "/coredns",
  //       "-conf",
  //       "/config/scripts/Corefile"
  //     ],
  //     "subnet": "customdns"
  //   }

  // naming : Naming module object

param location string = resourceGroup().location
param naming object
param aci_object object
param tags object = {}

targetScope = 'resourceGroup'



resource containerGroup 'Microsoft.ContainerInstance/containerGroups@2021-09-01' = {
  name:  naming.containerGroup.name
  location: location
  properties: {
    containers: [
      {
        name: naming.containerGroup.name
        properties: {
          command: aci_object.commandline
          image: aci_object.image
          ports: [
            {
              port: aci_object.port
              protocol: aci_object.protocol
            }
          ]
          resources: {
            requests: {
              cpu: aci_object.cpuCores
              memoryInGB: aci_object.memoryInGb
            }
          }
          volumeMounts: [
            {
            name: 'gitrepo'
            mountPath: aci_object.gitrepomountpath
            }
          ]
        }
      }
    ]
    osType: 'Linux'
    restartPolicy: aci_object.restartPolicy
    subnetIds: [
      {
        id: resourceId('Microsoft.Network/VirtualNetworks/subnets',  naming.virtualNetwork.name, aci_object.subnet)
      }
    ]
    ipAddress: {
      type: 'Private'
      ports: [
        {
          port: aci_object.port
          protocol: aci_object.protocol
        }
      ]
    }
    volumes: [
      {
        name: 'gitrepo'
        gitRepo: {
          directory: '.'
          repository: aci_object.gitrepourl
        }
      }
    ]
  }
}


output ipaddress string = containerGroup.properties.ipAddress.ip
