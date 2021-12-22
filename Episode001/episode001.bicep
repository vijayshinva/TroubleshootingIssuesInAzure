resource networkSecurityGroup 'Microsoft.Network/networkSecurityGroups@2019-11-01' = {
  name: 'nsg-apps-${uniqueString(subscription().subscriptionId, resourceGroup().name)}'
  location: resourceGroup().location
  properties: {
    securityRules: [
      {
        name: 'Allow-HTTPS-Inbound'
        properties: {
          description: 'Allow HTTPS'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '443'
          sourceAddressPrefix: 'VirtualNetwork'
          destinationAddressPrefix: 'VirtualNetwork'
          access: 'Allow'
          priority: 100
          direction: 'Inbound'
        }
      }
      {
        name: 'Deny-All-Inbound'
        properties: {
          description: 'Deny All Inbound'
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRange: '*'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
          access: 'Deny'
          priority: 4096
          direction: 'Inbound'
        }
      }
      {
        name: 'Allow-HTTPS-Outbound'
        properties: {
          description: 'Allow HTTPS Outbound'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '443'
          sourceAddressPrefix: 'VirtualNetwork'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 103
          direction: 'Outbound'
        }
      }
      {
        name: 'Deny-All-Outbound'
        properties: {
          description: 'Deny All Outbound'
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRange: '*'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
          access: 'Deny'
          priority: 4096
          direction: 'Outbound'
        }
      }
    ]
  }
}

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2019-11-01' = {
  name: 'vnet-${uniqueString(subscription().subscriptionId, resourceGroup().name)}'
  location: resourceGroup().location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.13.0.0/16'
      ]
    }
    subnets: [
      {
        name: 'snet-apps'
        properties: {
          addressPrefix: '10.13.13.0/24'
          networkSecurityGroup: {
            id: networkSecurityGroup.id
          }
          delegations: [
            {
              name: 'Microsoft.Web.serverfarms'
              properties: {
                serviceName: 'Microsoft.Web/serverfarms'
              }
            }
          ]
        }
      }
    ]
  }
}

resource appServicePlan 'Microsoft.Web/serverfarms@2020-12-01' = {
  name: 'plan-${uniqueString(subscription().subscriptionId, resourceGroup().name)}'
  location: resourceGroup().location
  sku: {
    name: 'S1'
    capacity: 1
  }
  kind: 'linux'
  properties: {
    reserved: true
  }
}

resource webApplication 'Microsoft.Web/sites@2021-02-01' = {
  name: 'app-${uniqueString(subscription().subscriptionId, resourceGroup().name)}'
  location: resourceGroup().location
  tags: {
    'hidden-related:${resourceGroup().id}/providers/Microsoft.Web/serverfarms/appServicePlan': 'Resource'
  }
  properties: {
    serverFarmId: appServicePlan.id
    siteConfig: {
      appCommandLine: 'apt update && apt install -y postgre-client && dotnet AspNetOneRazor.dll'
      linuxFxVersion: 'DOTNETCORE|6.0'
      ftpsState: 'Disabled'
      vnetRouteAllEnabled: true
    }
    clientAffinityEnabled: false
    httpsOnly: true
    virtualNetworkSubnetId: virtualNetwork.properties.subnets[0].id
  }
  kind: 'app,linux'
}

resource symbolicname 'Microsoft.Web/sites/config@2021-02-01' = {
  parent: webApplication
  name: 'appsettings'
  kind: 'string'
  properties: {
    'PROJECT': 'AspNetOneRazor/AspNetOneRazor.csproj'
    'DISABLE_HUGO_BUILD': 'true'
  }
}

resource srcControls 'Microsoft.Web/sites/sourcecontrols@2021-01-01' = {
  parent: webApplication
  name: 'web'
  properties: {
    repoUrl: 'https://github.com/vijayshinva/TroubleshootingIssuesInAzureCode.git'
    branch: 'main'
    isManualIntegration: true
  }
}
