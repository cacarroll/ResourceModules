# Modules Usage

This section gives you an overview of how to use the bicep modules.

---

### _Navigation_

- [Deploy template](#deploy-template)
  - [Deploy local template](#deploy-local-template)
    - [**Local:** PowerShell](#local-powershell)
    - [**Local:** Azure CLI](#local-azure-cli)
  - [Deploy remote template](#deploy-remote-template)
    - [**Remote:** PowerShell](#remote-powershell)
    - [**Remote:** Azure CLI](#remote-azure-cli)
- [Orchestrate deployment](#orchestrate-deployment)
  - [Template-orchestration](#template-orchestration)
---

## Deploy template

This section shows you how to deploy a bicep template.

### Deploy local template

This sub-section gives you an example on how to deploy a template from your local drive.

#### **Local:** PowerShell

This example targets a resource group level template.

```PowerShell
New-AzResourceGroup -Name 'ExampleGroup' -Location "Central US"

$inputObject = @{
 DeploymentName    = 'ExampleDeployment'
 ResourceGroupName = 'ExampleGroup'
 TemplateFile      = "$home\ResourceModules\arm\Microsoft.KeyVault\vault\deploy.bicep"
}
New-AzResourceGroupDeployment @inputObject
```

#### **Local:** Azure CLI

This example targets a resource group level template.

```bash
az group create --name 'ExampleGroup' --location "Central US"
$inputObject = @(
    '--name',           'ExampleDeployment',
    '--resource-group', 'ExampleGroup',
    '--template-file',  "$home\ResourceModules\arm\Microsoft.KeyVault\vault\deploy.bicep",
    '--parameters',     'storageAccountType=Standard_GRS',
)
az deployment group create @inputObject
```

### Deploy remote template

This section gives you an example on how to deploy a template that is stored at a publicly available remote location.

#### **Remote:** PowerShell

```PowerShell
New-AzResourceGroup -Name 'ExampleGroup' -Location "Central US"

$inputObject = @{
 DeploymentName    = 'ExampleDeployment'
 ResourceGroupName = 'ExampleGroup'
 TemplateUri       = 'https://raw.githubusercontent.com/arm/ResourceModules/main/arm/Microsoft.KeyVault/vaults/deploy.json'
}
New-AzResourceGroupDeployment @inputObject
```

#### **Remote:** Azure CLI

```bash
az group create --name 'ExampleGroup' --location "Central US"

$inputObject = @(
    '--name',           'ExampleDeployment',
    '--resource-group', 'ExampleGroup',
    '--template-uri',   'https://raw.githubusercontent.com/arm/ResourceModules/main/arm/Microsoft.KeyVault/vaults/deploy.json',
    '--parameters',     'storageAccountType=Standard_GRS',
)
az deployment group create @inputObject
```

## Orchestrate deployment

This section shows you how you can orchestrate a deployment using multiple resource modules

### Template-orchestration

The _template-orchestrated_ approach means using a _main_ or so-called _master template_ for deploying resources in Azure. The _master template_ will only contain nested deployments, where the modules – instead of embedding their content into the _master template_ – will be linked from the _master template_.

With this approach, modules need to be stored in an available location, where Azure Resource Manager (ARM) can access them. This can be achieved by storing the modules templates in an accessible location location like _template specs_ or the _bicep registry_.

In an enterprise environment, the recommended approach is to store these templates in a private environment, only accessible by enterprise resources. Thus, only trusted authorities can have access to these files.

#### Example with template-specs

The following example shows how you could orchestrate a deployment of multiple resources using template specs. In this example we will deploy a NSG and use the same in a subsequent VNET deployment.

```bicep
// ================ //
// Input Parameters //
// ================ //

// Network Security Group parameters
@description('Required. The name of the vnet to deploy')
param networkSecurityGroupName string = 'TemplateSpecDemoNsg'

// Virtual Network parameters
@description('Required. The name of the vnet to deploy')
param vnetName string = 'TemplateSpecDemoVnet'

@description('Required. An Array of 1 or more IP Address Prefixes for the Virtual Network.')
param vNetAddressPrefixes array = [
  '10.0.0.0/16'
]

@description('Required. An Array of subnets to deploy to the Virual Network.')
param subnets array = [
  {
    name: 'PrimrarySubnet'
    addressPrefix: '10.0.0.0/24'
    networkSecurityGroupName: networkSecurityGroupName
  }
  {
    name: 'SecondarySubnet'
    addressPrefix: '10.0.1.0/24'
    networkSecurityGroupName: networkSecurityGroupName
  }
]

// ========================= //
// Template Specs References //
// ========================= //
var templateSpecSub = '6ec6c303-4769-4857-b5fb-819de3a5ba4a'
var templateSpecRg = 'artifacts-rg'

// Network Security Group
resource nsgTemplate 'Microsoft.Resources/templateSpecs/versions@2021-05-01' existing = {
  scope: resourceGroup(templateSpecSub, templateSpecRg)
  name: 'networkSecurityGroups/1.0.21'
}

// Virtual Network
resource vnetTemplate 'Microsoft.Resources/templateSpecs/versions@2021-05-01' existing = {
  scope: resourceGroup(templateSpecSub, templateSpecRg)
  name: 'VirtualNetwork/1.0.12'
}

// =========== //
// Deployments //
// =========== //

// Network Security Group
resource nsg 'Microsoft.Resources/deployments@2021-01-01' = {
  name: 'nsgDeployment'
  properties: {
    mode: 'Incremental'
    templateLink: {
      id: nsgTemplate.id
    }
    parameters: {
      networkSecurityGroupName: {
        value: networkSecurityGroupName
      }
    }
  }
}

// Virtual Network
resource vnet 'Microsoft.Resources/deployments@2021-01-01' = {
  name: 'vnetDeployment'
  properties: {
    mode: 'Incremental'
    templateLink: {
      id: vnetTemplate.id
    }
    parameters: {
      vnetName: {
        value: vnetName
      }
      vNetAddressPrefixes: {
        value: vNetAddressPrefixes
      }
      subnets: {
        value: subnets
      }
    }
  }
  dependsOn: [
    nsg
  ]
}
```
