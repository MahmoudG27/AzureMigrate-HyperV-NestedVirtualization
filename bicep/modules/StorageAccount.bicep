@description('Storage Account Name')
param storageAccountName string

@description('Azure Region')
param location string = resourceGroup().location

@description('Storage SKU')
param skuName string = 'Standard_LRS'


resource storageAccount 'Microsoft.Storage/storageAccounts@2023-01-01' = {

  name: storageAccountName

  location: location


  sku: {

    name: skuName

  }


  kind: 'StorageV2'


  properties: {


    supportsHttpsTrafficOnly: true


    minimumTlsVersion: 'TLS1_2'


    allowBlobPublicAccess: false


    accessTier: 'Hot'


    encryption: {

      keySource: 'Microsoft.Storage'


      services: {

        blob: {

          enabled: true

        }


        file: {

          enabled: true

        }

      }

    }

  }

}


output blobUri string = storageAccount.properties.primaryEndpoints.blob
