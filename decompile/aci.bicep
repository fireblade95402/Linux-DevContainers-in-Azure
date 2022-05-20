param containerGroups_dev_dnsforwarder_aci_name string = 'dev-dnsforwarder-aci'
param virtualNetworks_dev_vnet_externalid string = '/subscriptions/461377a7-433d-4980-9506-c35defb10a49/resourceGroups/development/providers/Microsoft.Network/virtualNetworks/dev-vnet'

resource containerGroups_dev_dnsforwarder_aci_name_resource 'Microsoft.ContainerInstance/containerGroups@2021-10-01' = {
  name: containerGroups_dev_dnsforwarder_aci_name
  location: 'uksouth'
  properties: {
    sku: 'Standard'
    containers: [
      {
        name: containerGroups_dev_dnsforwarder_aci_name
        properties: {
          image: 'coredns/coredns:latest'
          command: [
            '/coredns'
            '-conf'
            '/config/host/Corefile'
          ]
          ports: [
            {
              protocol: 'UDP'
              port: 53
            }
          ]
          environmentVariables: []
          resources: {
            requests: {
              memoryInGB: '0.5'
              cpu: 1
            }
          }
          volumeMounts: [
            {
              name: 'gitrepo'
              mountPath: '/config'
            }
          ]
        }
      }
    ]
    initContainers: []
    restartPolicy: 'Always'
    ipAddress: {
      ports: [
        {
          protocol: 'UDP'
          port: 53
        }
      ]
      ip: '10.1.3.4'
      type: 'Private'
    }
    osType: 'Linux'
    volumes: [
      {
        name: 'gitrepo'
        gitRepo: {
          repository: 'https://github.com/Sam-Rowe/Remote-DevContainers-Extras'
          directory: '.'
        }
      }
    ]
    subnetIds: [
      {
        id: '${virtualNetworks_dev_vnet_externalid}/subnets/customdns'
      }
    ]
  }
}