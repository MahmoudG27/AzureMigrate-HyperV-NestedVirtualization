param vmName string
param location string
param vmSize string

param adminUsername string
param adminPassword string

param subnetId string

param diagnosticsStorageUri string

param dataDiskSize int

param imagePublisher string
param imageOffer string
param imageSku string
param imageVersion string

param licenseType string = 'Windows_Server'


var nicName = '${vmName}-nic'
var pipName = '${vmName}-pip'
var nsgName = '${vmName}-nsg'
var osDiskName = '${vmName}-osdisk'
var dataDiskName = '${vmName}-datadisk'


//
// Network Security Group
//

resource nsg 'Microsoft.Network/networkSecurityGroups@2023-09-01' = {

  name: nsgName

  location: location

  properties: {

    securityRules: [

      {
        name: 'Allow-RDP'

        properties: {

          priority: 100

          direction: 'Inbound'

          access: 'Allow'

          protocol: 'Tcp'

          sourcePortRange: '*'

          destinationPortRange: '3389'

          sourceAddressPrefix: '*'

          destinationAddressPrefix: '*'
        }
      }
    ]
  }
}



//
// Public IP
//

resource pip 'Microsoft.Network/publicIPAddresses@2023-09-01' = {

  name: pipName

  location: location

  sku: {

    name: 'Standard'

  }

  properties: {

    publicIPAllocationMethod: 'Static'

  }
}



//
// Network Interface
//

resource nic 'Microsoft.Network/networkInterfaces@2023-09-01' = {

  name: nicName

  location: location

  properties: {

    enableAcceleratedNetworking: true

    ipConfigurations: [

      {

        name: 'ipconfig1'

        properties: {

          privateIPAllocationMethod: 'Dynamic'

          subnet: {

            id: subnetId

          }

          publicIPAddress: {

            id: pip.id

          }

        }

      }

    ]

    networkSecurityGroup: {

      id: nsg.id

    }

  }

}



//
// Virtual Machine
//

resource vm 'Microsoft.Compute/virtualMachines@2023-09-01' = {

  name: vmName

  location: location


  properties: {


    hardwareProfile: {

      vmSize: vmSize

    }


    storageProfile: {


      imageReference: {

        publisher: imagePublisher

        offer: imageOffer

        sku: imageSku

        version: imageVersion

      }


      osDisk: {

        name: osDiskName

        createOption: 'FromImage'

        managedDisk: {

          storageAccountType: 'StandardSSD_LRS'

        }

      }


      dataDisks: [

        {

          name: dataDiskName

          lun: 0

          diskSizeGB: dataDiskSize

          createOption: 'Empty'

          managedDisk: {

            storageAccountType: 'StandardSSD_LRS'

          }

        }

      ]

    }



    osProfile: {

      computerName: vmName

      adminUsername: adminUsername

      adminPassword: adminPassword

    }



    licenseType: licenseType



    networkProfile: {

      networkInterfaces: [

        {

          id: nic.id

        }

      ]

    }



    diagnosticsProfile: {

      bootDiagnostics: {

        enabled: true

        storageUri: diagnosticsStorageUri

      }

    }



    securityProfile: {

      securityType: 'Standard'

    }

  }


  dependsOn: [

    nic

  ]

}




//
// Install Hyper-V Automatically
//

resource hypervExtension 'Microsoft.Compute/virtualMachines/extensions@2023-09-01' = {

  parent: vm

  name: 'install-hyperv'

  location: location


  properties: {

    publisher: 'Microsoft.Compute'

    type: 'CustomScriptExtension'

    typeHandlerVersion: '1.10'


    settings: {

      fileUris: []

      commandToExecute: 'powershell.exe -ExecutionPolicy Unrestricted -Command "Install-WindowsFeature -Name Hyper-V -IncludeManagementTools -Restart"'

    }

  }

}



output vmId string = vm.id
