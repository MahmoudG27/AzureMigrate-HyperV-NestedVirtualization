targetScope = 'resourceGroup'

@description('Deployment location')
param location string = resourceGroup().location

@description('VM Name')
param vmName string = 'hyperv'

@description('Virtual Machine Size')
param vmSize string = 'Standard_D16as_v5'
// Examples:
// Standard_D8as_v5
// Standard_D16as_v5
// Standard_D16s_v5

@description('Administrator Username')
param adminUsername string = 'azureadmin'

@secure()
@description('Administrator Password')
param adminPassword string

@description('Data Disk Size (GB)')
param dataDiskSize int = 1024

@description('Virtual Network Name')
param vnetName string = 'vnet-hyperv'

@description('Address Space')
param addressSpace string = '10.221.0.0/24'

@description('Subnet Prefix')
param subnetPrefix string = '10.221.0.0/24'

//
// Virtual Network
//

module vnet './modules/Vnet.bicep' = {
  name: 'vnet'
  params: {
    location: location
    vnetName: vnetName
    addressPrefix: addressSpace
    subnetPrefix: subnetPrefix
  }
}

//
// Windows Hyper-V Host
//

module hyperv './modules/Vm.bicep' = {
  name: 'hyperv'

  params: {

    vmName: vmName

    location: location

    vmSize: vmSize

    adminUsername: adminUsername

    adminPassword: adminPassword

    subnetId: vnet.outputs.subnetId

    dataDiskSize: dataDiskSize

    imagePublisher: 'MicrosoftWindowsServer'

    imageOffer: 'WindowsServer'

    imageSku: '2022-datacenter'

    imageVersion: 'latest'

    licenseType: 'Windows_Server'
  }

  dependsOn: [
    vnet
  ]
}

output vmId string = hyperv.outputs.vmId

output vmName string = vmName
