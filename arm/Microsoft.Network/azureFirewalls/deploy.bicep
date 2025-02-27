@description('Required. Name of the Azure Firewall.')
param azureFirewallName string

@description('Optional. Name of an Azure Firewall SKU.')
@allowed([
  'AZFW_VNet'
  'AZFW_Hub'
])
param azureSkuName string = 'AZFW_VNet'

@description('Optional. Tier of an Azure Firewall.')
@allowed([
  'Standard'
  'Premium'
])
param azureSkuTier string = 'Standard'

@description('Optional. Enable the preview feature for DNS proxy.')
param enableDnsProxy bool = false

@description('Optional. Collection of application rule collections used by Azure Firewall.')
param applicationRuleCollections array = []

@description('Optional. Collection of network rule collections used by Azure Firewall.')
param networkRuleCollections array = []

@description('Optional. Collection of NAT rule collections used by Azure Firewall.')
param natRuleCollections array = []

@description('Required. Shared services Virtual Network resource Id')
param vNetId string

@description('Optional. Specifies the name of the Public IP used by Azure Firewall. If it\'s not provided, a \'-pip\' suffix will be appended to the Firewall\'s name.')
param azureFirewallPipName string = ''

@description('Optional. Resource Id of the Public IP Prefix object. This is only needed if you want your Public IPs created in a PIP Prefix.')
param publicIPPrefixId string = ''

@description('Optional. Diagnostic Storage Account resource identifier')
param diagnosticStorageAccountId string = ''

@description('Optional. Log Analytics workspace resource identifier')
param workspaceId string = ''

@description('Optional. Specifies the number of days that logs will be kept for; a value of 0 will retain data indefinitely.')
@minValue(0)
@maxValue(365)
param diagnosticLogsRetentionInDays int = 365

@description('Optional. Resource ID of the event hub authorization rule for the Event Hubs namespace in which the event hub should be created or streamed to.')
param eventHubAuthorizationRuleId string = ''

@description('Optional. Name of the event hub within the namespace to which logs are streamed. Without this, an event hub is created for each log category.')
param eventHubName string = ''

@description('Optional. Location for all resources.')
param location string = resourceGroup().location

@description('Optional. Zone numbers e.g. 1,2,3.')
param availabilityZones array = [
  '1'
  '2'
  '3'
]

@allowed([
  'CanNotDelete'
  'NotSpecified'
  'ReadOnly'
])
@description('Optional. Specify the type of lock.')
param lock string = 'NotSpecified'

@description('Optional. Array of role assignment objects that contain the \'roleDefinitionIdOrName\' and \'principalId\' to define RBAC role assignments on this resource. In the roleDefinitionIdOrName attribute, you can provide either the display name of the role definition, or its fully qualified ID in the following format: \'/providers/Microsoft.Authorization/roleDefinitions/c2f4ef07-c644-48eb-af81-4b1b4947fb11\'')
param roleAssignments array = []

@description('Optional. Tags of the Automation Account resource.')
param tags object = {}

@description('Optional. Customer Usage Attribution id (GUID). This GUID must be previously registered')
param cuaId string = ''

var publicIPPrefix = {
  id: publicIPPrefixId
}
var azureFirewallSubnetId = '${vNetId}/subnets/AzureFirewallSubnet'
var azureFirewallPipName_var = (empty(azureFirewallPipName) ? '${azureFirewallName}-pip' : azureFirewallPipName)
var azureFirewallPipId = azureFirewallPip.id

@description('Optional. The name of firewall logs that will be streamed.')
@allowed([
  'AzureFirewallApplicationRule'
  'AzureFirewallNetworkRule'
  'AzureFirewallDnsProxy'
])
param firewallLogsToEnable array = [
  'AzureFirewallApplicationRule'
  'AzureFirewallNetworkRule'
  'AzureFirewallDnsProxy'
]

@description('Optional. The name of public IP logs that will be streamed.')
@allowed([
  'DDoSProtectionNotifications'
  'DDoSMitigationReports'
  'DDoSMitigationFlowLogs'
])
param publicIPLogsToEnable array = [
  'DDoSProtectionNotifications'
  'DDoSMitigationReports'
  'DDoSMitigationFlowLogs'
]

@description('Optional. The name of metrics that will be streamed.')
@allowed([
  'AllMetrics'
])
param metricsToEnable array = [
  'AllMetrics'
]

var diagnosticsLogsAzureFirewall = [for log in firewallLogsToEnable: {
  category: log
  enabled: true
  retentionPolicy: {
    enabled: true
    days: diagnosticLogsRetentionInDays
  }
}]

var diagnosticsLogsPublicIp = [for log in publicIPLogsToEnable: {
  category: log
  enabled: true
  retentionPolicy: {
    enabled: true
    days: diagnosticLogsRetentionInDays
  }
}]

var diagnosticsMetrics = [for metric in metricsToEnable: {
  category: metric
  timeGrain: null
  enabled: true
  retentionPolicy: {
    enabled: true
    days: diagnosticLogsRetentionInDays
  }
}]

module pid_cuaId '.bicep/nested_cuaId.bicep' = if (!empty(cuaId)) {
  name: 'pid-${cuaId}'
  params: {}
}

resource azureFirewallPip 'Microsoft.Network/publicIPAddresses@2021-02-01' = {
  name: azureFirewallPipName_var
  location: location
  tags: tags
  sku: {
    name: 'Standard'
  }
  zones: availabilityZones
  properties: {
    publicIPAllocationMethod: 'Static'
    publicIPAddressVersion: 'IPv4'
    publicIPPrefix: ((!empty(publicIPPrefixId)) ? publicIPPrefix : json('null'))
  }
}

resource azureFirewallPip_lock 'Microsoft.Authorization/locks@2016-09-01' = if (lock != 'NotSpecified') {
  name: '${azureFirewallPip.name}-${lock}-lock'
  properties: {
    level: lock
    notes: (lock == 'CanNotDelete') ? 'Cannot delete resource or child resources.' : 'Cannot modify the resource or child resources.'
  }
  scope: azureFirewallPip
}

resource azureFirewallPip_diagnosticSettings 'Microsoft.Insights/diagnosticsettings@2017-05-01-preview' = if ((!empty(diagnosticStorageAccountId)) || (!empty(workspaceId)) || (!empty(eventHubAuthorizationRuleId)) || (!empty(eventHubName))) {
  name: '${azureFirewallPip.name}-diagnosticSettings'
  properties: {
    storageAccountId: (empty(diagnosticStorageAccountId) ? json('null') : diagnosticStorageAccountId)
    workspaceId: (empty(workspaceId) ? json('null') : workspaceId)
    eventHubAuthorizationRuleId: (empty(eventHubAuthorizationRuleId) ? json('null') : eventHubAuthorizationRuleId)
    eventHubName: (empty(eventHubName) ? json('null') : eventHubName)
    metrics: ((empty(diagnosticStorageAccountId) && empty(workspaceId) && empty(eventHubAuthorizationRuleId) && empty(eventHubName)) ? json('null') : diagnosticsMetrics)
    logs: ((empty(diagnosticStorageAccountId) && empty(workspaceId) && empty(eventHubAuthorizationRuleId) && empty(eventHubName)) ? json('null') : diagnosticsLogsPublicIp)
  }
  scope: azureFirewallPip
}

resource azureFirewall 'Microsoft.Network/azureFirewalls@2021-02-01' = {
  name: azureFirewallName
  location: location
  zones: ((length(availabilityZones) == 0) ? json('null') : availabilityZones)
  tags: tags
  properties: {
    threatIntelMode: 'Deny'
    ipConfigurations: [
      {
        name: 'IpConf'
        properties: {
          subnet: {
            id: azureFirewallSubnetId
          }
          publicIPAddress: {
            id: azureFirewallPipId
          }
        }
      }
    ]
    sku: {
      name: azureSkuName
      tier: azureSkuTier
    }
    additionalProperties: {
      'Network.DNS.EnableProxy': string(enableDnsProxy)
    }
    applicationRuleCollections: applicationRuleCollections
    natRuleCollections: natRuleCollections
    networkRuleCollections: networkRuleCollections
  }
}

resource azureFirewall_lock 'Microsoft.Authorization/locks@2016-09-01' = if (lock != 'NotSpecified') {
  name: '${azureFirewall.name}-${lock}-lock'
  properties: {
    level: lock
    notes: (lock == 'CanNotDelete') ? 'Cannot delete resource or child resources.' : 'Cannot modify the resource or child resources.'
  }
  scope: azureFirewall
}

resource azureFirewall_diagnosticSettings 'Microsoft.Insights/diagnosticsettings@2017-05-01-preview' = if ((!empty(diagnosticStorageAccountId)) || (!empty(workspaceId)) || (!empty(eventHubAuthorizationRuleId)) || (!empty(eventHubName))) {
  name: '${azureFirewall.name}-diagnosticSettings'
  properties: {
    storageAccountId: (empty(diagnosticStorageAccountId) ? json('null') : diagnosticStorageAccountId)
    workspaceId: (empty(workspaceId) ? json('null') : workspaceId)
    eventHubAuthorizationRuleId: (empty(eventHubAuthorizationRuleId) ? json('null') : eventHubAuthorizationRuleId)
    eventHubName: (empty(eventHubName) ? json('null') : eventHubName)
    metrics: ((empty(diagnosticStorageAccountId) && empty(workspaceId) && empty(eventHubAuthorizationRuleId) && empty(eventHubName)) ? json('null') : diagnosticsMetrics)
    logs: ((empty(diagnosticStorageAccountId) && empty(workspaceId) && empty(eventHubAuthorizationRuleId) && empty(eventHubName)) ? json('null') : diagnosticsLogsAzureFirewall)
  }
  scope: azureFirewall
}

module azureFirewall_rbac '.bicep/nested_rbac.bicep' = [for (roleAssignment, index) in roleAssignments: {
  name: '${deployment().name}-rbac-${index}'
  params: {
    roleAssignmentObj: roleAssignment
    resourceName: azureFirewall.name
  }
}]

output azureFirewallResourceId string = azureFirewall.id
output azureFirewallName string = azureFirewall.name
output azureFirewallResourceGroup string = resourceGroup().name
output azureFirewallPrivateIp string = azureFirewall.properties.ipConfigurations[0].properties.privateIPAddress
output azureFirewallPublicIp string = azureFirewallPip.properties.ipAddress
output applicationRuleCollections array = applicationRuleCollections
output networkRuleCollections array = networkRuleCollections
output natRuleCollections array = natRuleCollections
