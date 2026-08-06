@description('Azure Region')
param location string = resourceGroup().location

@description('Virtual Network Name')
param vnetName string

@description('VNet Address Space')
param addressPrefix string = '10.221.0.0/24'

@description('Subnet Address Prefix')
param subnetPrefix string = '10.221.0.0/24'


resource vnet 'Microsoft.Network/virtualNetworks@2023-09-01' = {

  name: vnetName

  location: location


  properties: {

    addressSpace: {

      addressPrefixes: [

        addressPrefix

      ]

    }


    subnets: [

      {

        name: 'default'


        properties: {

          addressPrefix: subnetPrefix

        }

      }

    ]

  }

}


output vnetId string = vnet.id

output subnetId string = '${vnet.id}/subnets/default'
