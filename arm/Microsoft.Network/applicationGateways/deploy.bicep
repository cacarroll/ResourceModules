@description('Required. The name to be used for the Application Gateway.')
param applicationGatewayName string

@description('Optional. The name of the SKU for the Application Gateway.')
@allowed([
  'Standard_Small'
  'Standard_Medium'
  'Standard_Large'
  'WAF_Medium'
  'WAF_Large'
  'Standard_v2'
  'WAF_v2'
])
param sku string = 'WAF_Medium'

@description('Optional. The number of Application instances to be configured.')
@minValue(1)
@maxValue(10)
param capacity int = 2

@description('Optional. Enables HTTP/2 support.')
param http2Enabled bool = true

@description('Required. PublicIP Resource Id used in Public Frontend.')
param frontendPublicIpResourceId string

@metadata({
  description: 'Optional. The private IP within the Application Gateway subnet to be used as frontend private address.'
  limitations: 'The IP must be available in the configured subnet. If empty, allocation method will be set to dynamic. Once a method (static or dynamic) has been configured, it cannot be changed'
})
param frontendPrivateIpAddress string = ''

@description('Required. The name of the Virtual Network where the Application Gateway will be deployed.')
param vNetName string

@description('Required. The name of Gateway Subnet Name where the Application Gateway will be deployed.')
param subnetName string

@description('Optional. The name of the Virtual Network Resource Group where the Application Gateway will be deployed.')
param vNetResourceGroup string = resourceGroup().name

@description('Optional. The Subscription Id of the Virtual Network where the Application Gateway will be deployed.')
param vNetSubscriptionId string = subscription().subscriptionId

@description('Optional. Resource Id of an User assigned managed identity which will be associated with the App Gateway.')
param managedIdentityResourceId string = ''

@description('Optional. Application Gateway IP configuration name.')
param gatewayIpConfigurationName string = 'gatewayIpConfiguration01'

@description('Optional. SSL certificate reference name for a certificate stored in the Key Vault to configure the HTTPS listeners.')
param sslCertificateName string = 'sslCertificate01'

@description('Optional. Secret Id of the SSL certificate stored in the Key Vault that will be used to configure the HTTPS listeners.')
param sslCertificateKeyVaultSecretId string = ''

@description('Required. The backend pools to be configured.')
param backendPools array

@description('Required. The backend HTTP settings to be configured. These HTTP settings will be used to rewrite the incoming HTTP requests for the backend pools.')
param backendHttpConfigurations array

@description('Optional. The backend HTTP settings probes to be configured.')
param probes array = []

@description('Required. The frontend http listeners to be configured.')
param frontendHttpListeners array = []

@description('Required. The frontend https listeners to be configured.')
param frontendHttpsListeners array = []

@description('Optional. The http redirects to be configured. Each redirect will route http traffic to a pre-defined frontEnd https listener.')
param frontendHttpRedirects array = []

@description('Required. The routing rules to be configured. These rules will be used to route requests from frontend listeners to backend pools using a backend HTTP configuration.')
param routingRules array

@description('Optional. Location for all Resources.')
param location string = resourceGroup().location

@description('Optional. Specifies the number of days that logs will be kept for; a value of 0 will retain data indefinitely.')
@minValue(0)
@maxValue(365)
param diagnosticLogsRetentionInDays int = 365

@description('Optional. Resource identifier of the Diagnostic Storage Account.')
param diagnosticStorageAccountId string = ''

@description('Optional. Resource identifier of Log Analytics.')
param workspaceId string = ''

@description('Optional. Resource ID of the event hub authorization rule for the Event Hubs namespace in which the event hub should be created or streamed to.')
param eventHubAuthorizationRuleId string = ''

@description('Optional. Name of the event hub within the namespace to which logs are streamed. Without this, an event hub is created for each log category.')
param eventHubName string = ''

@allowed([
  'CanNotDelete'
  'NotSpecified'
  'ReadOnly'
])
@description('Optional. Specify the type of lock.')
param lock string = 'NotSpecified'

@description('Optional. Array of role assignment objects that contain the \'roleDefinitionIdOrName\' and \'principalId\' to define RBAC role assignments on this resource. In the roleDefinitionIdOrName attribute, you can provide either the display name of the role definition, or its fully qualified ID in the following format: \'/providers/Microsoft.Authorization/roleDefinitions/c2f4ef07-c644-48eb-af81-4b1b4947fb11\'')
param roleAssignments array = []

@description('Optional. Tags of the resource.')
param tags object = {}

@description('Optional. Customer Usage Attribution id (GUID). This GUID must be previously registered.')
param cuaId string = ''

@description('Optional. The name of logs that will be streamed.')
@allowed([
  'ApplicationGatewayAccessLog'
  'ApplicationGatewayPerformanceLog'
  'ApplicationGatewayFirewallLog'
])
param logsToEnable array = [
  'ApplicationGatewayAccessLog'
  'ApplicationGatewayPerformanceLog'
  'ApplicationGatewayFirewallLog'
]

@description('Optional. The name of metrics that will be streamed.')
@allowed([
  'AllMetrics'
])
param metricsToEnable array = [
  'AllMetrics'
]

var diagnosticsLogs = [for log in logsToEnable: {
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

var applicationGatewayResourceId = resourceId('Microsoft.Network/applicationGateways', applicationGatewayName)
var subnetResourceId = resourceId(vNetSubscriptionId, vNetResourceGroup, 'Microsoft.Network/virtualNetworks/subnets', vNetName, subnetName)
var frontendPublicIPConfigurationName = 'public'
var frontendPrivateIPConfigurationName = 'private'
var frontendPrivateIPDynamicConfiguration = {
  privateIPAllocationMethod: 'Dynamic'
  subnet: {
    id: subnetResourceId
  }
}
var frontendPrivateIPStaticConfiguration = {
  privateIPAllocationMethod: 'Static'
  privateIPAddress: frontendPrivateIpAddress
  subnet: {
    id: subnetResourceId
  }
}
var redirectConfigurationsHttpRedirectNamePrefix = 'httpRedirect'
var httpListenerhttpRedirectNamePrefix = 'httpRedirect'
var requestRoutingRuleHttpRedirectNamePrefix = 'httpRedirect'
var wafConfiguration = {
  enabled: true
  firewallMode: 'Detection'
  ruleSetType: 'OWASP'
  ruleSetVersion: '3.0'
  disabledRuleGroups: []
  requestBodyCheck: true
  maxRequestBodySizeInKb: '128'
}
var sslCertificates = [
  {
    name: sslCertificateName
    properties: {
      keyVaultSecretId: sslCertificateKeyVaultSecretId
    }
  }
]
var frontendPorts = concat((empty(frontendHttpListeners) ? frontendHttpListeners : frontendHttpPorts), (empty(frontendHttpsListeners) ? frontendHttpsListeners : frontendHttpsPorts), (empty(frontendHttpRedirects) ? frontendHttpRedirects : frontendHttpRedirectPorts))
var httpListeners = concat((empty(frontendHttpListeners) ? frontendHttpListeners : frontendHttpListeners_var), (empty(frontendHttpsListeners) ? frontendHttpsListeners : frontendHttpsListeners_var), (empty(frontendHttpRedirects) ? frontendHttpRedirects : frontendHttpRedirects_var))
var redirectConfigurations = (empty(frontendHttpRedirects) ? frontendHttpRedirects : httpRedirectConfigurations)
var requestRoutingRules = concat(httpsRequestRoutingRules, (empty(frontendHttpRedirects) ? frontendHttpRedirects : httpRequestRoutingRules))
var identity = {
  type: 'UserAssigned'
  userAssignedIdentities: {
    '${managedIdentityResourceId}': {}
  }
}

var backendAddressPools = [for backendPool in backendPools: {
  name: backendPool.backendPoolName
  type: 'Microsoft.Network/applicationGateways/backendAddressPools'
  properties: {
    backendAddresses: (contains(backendPool, 'BackendAddresses') ? backendPool.BackendAddresses : [])
  }
}]
var probes_var = [for probe in probes: {
  name: '${probe.backendHttpConfigurationName}Probe'
  type: 'Microsoft.Network/applicationGateways/probes'
  properties: {
    protocol: probe.protocol
    host: probe.host
    path: probe.path
    interval: (contains(probe, 'interval') ? probe.interval : 30)
    timeout: (contains(probe, 'timeout') ? probe.timeout : 30)
    unhealthyThreshold: (contains(probe, 'timeout') ? probe.unhealthyThreshold : 3)
    minServers: (contains(probe, 'timeout') ? probe.minServers : 0)
    match: {
      body: (contains(probe, 'timeout') ? probe.body : '')
      statusCodes: probe.statusCodes
    }
  }
}]
var backendHttpConfigurations_var = [for backendHttpConfiguration in backendHttpConfigurations: {
  name: backendHttpConfiguration.backendHttpConfigurationName
  properties: {
    port: backendHttpConfiguration.port
    protocol: backendHttpConfiguration.protocol
    cookieBasedAffinity: backendHttpConfiguration.cookieBasedAffinity
    pickHostNameFromBackendAddress: backendHttpConfiguration.pickHostNameFromBackendAddress
    probeEnabled: backendHttpConfiguration.probeEnabled
    probe: (bool(backendHttpConfiguration.probeEnabled) ? json('{"id": "${applicationGatewayResourceId}/probes/${backendHttpConfiguration.backendHttpConfigurationName}Probe"}') : json('null'))
  }
}]
var frontendHttpsPorts = [for frontendHttpsListener in frontendHttpsListeners: {
  name: 'port${frontendHttpsListener.port}'
  properties: {
    Port: frontendHttpsListener.port
  }
}]
var frontendHttpsListeners_var = [for frontendHttpsListener in frontendHttpsListeners: {
  name: frontendHttpsListener.frontendListenerName
  properties: {
    FrontendIPConfiguration: {
      Id: '${applicationGatewayResourceId}/frontendIPConfigurations/${frontendHttpsListener.frontendIPType}'
    }
    FrontendPort: {
      Id: '${applicationGatewayResourceId}/frontendPorts/port${frontendHttpsListener.port}'
    }
    Protocol: 'https'
    SslCertificate: {
      Id: '${applicationGatewayResourceId}/sslCertificates/${sslCertificateName}'
    }
  }
}]
var frontendHttpPorts = [for frontendHttpListener in frontendHttpListeners: {
  name: 'port${frontendHttpListener.port}'
  properties: {
    Port: frontendHttpListener.port
  }
}]
var frontendHttpListeners_var = [for frontendHttpListener in frontendHttpListeners: {
  name: frontendHttpListener.frontendListenerName
  properties: {
    FrontendIPConfiguration: {
      Id: '${applicationGatewayResourceId}/frontendIPConfigurations/${frontendHttpListener.frontendIPType}'
    }
    FrontendPort: {
      Id: '${applicationGatewayResourceId}/frontendPorts/port${frontendHttpListener.port}'
    }
    Protocol: 'http'
  }
}]
var httpsRequestRoutingRules = [for routingRule in routingRules: {
  name: '${routingRule.frontendListenerName}-${routingRule.backendHttpConfigurationName}-${routingRule.backendHttpConfigurationName}'
  properties: {
    RuleType: 'Basic'
    httpListener: {
      id: '${applicationGatewayResourceId}/httpListeners/${routingRule.frontendListenerName}'
    }
    backendAddressPool: {
      id: '${applicationGatewayResourceId}/backendAddressPools/${routingRule.backendPoolName}'
    }
    backendHttpSettings: {
      id: '${applicationGatewayResourceId}/backendHttpSettingsCollection/${routingRule.backendHttpConfigurationName}'
    }
  }
}]
var frontendHttpRedirectPorts = [for frontendHttpRedirect in frontendHttpRedirects: {
  name: 'port${frontendHttpRedirect.port}'
  properties: {
    Port: frontendHttpRedirect.port
  }
}]
var frontendHttpRedirects_var = [for frontendHttpRedirect in frontendHttpRedirects: {
  name: '${httpListenerhttpRedirectNamePrefix}${frontendHttpRedirect.port}'
  properties: {
    FrontendIPConfiguration: {
      Id: '${applicationGatewayResourceId}/frontendIPConfigurations/${frontendHttpRedirect.frontendIPType}'
    }
    FrontendPort: {
      Id: '${applicationGatewayResourceId}/frontendPorts/port${frontendHttpRedirect.port}'
    }
    Protocol: 'http'
  }
}]
var httpRequestRoutingRules = [for frontendHttpRedirect in frontendHttpRedirects: {
  name: '${requestRoutingRuleHttpRedirectNamePrefix}${frontendHttpRedirect.port}-${frontendHttpRedirect.frontendListenerName}'
  properties: {
    RuleType: 'Basic'
    httpListener: {
      id: '${applicationGatewayResourceId}/httpListeners/${httpListenerhttpRedirectNamePrefix}${frontendHttpRedirect.port}'
    }
    redirectConfiguration: {
      id: '${applicationGatewayResourceId}/redirectConfigurations/${redirectConfigurationsHttpRedirectNamePrefix}${frontendHttpRedirect.port}'
    }
  }
}]
var httpRedirectConfigurations = [for frontendHttpRedirect in frontendHttpRedirects: {
  name: '${redirectConfigurationsHttpRedirectNamePrefix}${frontendHttpRedirect.port}'
  properties: {
    redirectType: 'Permanent'
    includePath: true
    includeQueryString: true
    requestRoutingRules: [
      {
        id: '${applicationGatewayResourceId}/requestRoutingRules/${requestRoutingRuleHttpRedirectNamePrefix}${frontendHttpRedirect.port}-${frontendHttpRedirect.frontendListenerName}'
      }
    ]
    targetListener: {
      id: '${applicationGatewayResourceId}/httpListeners/${frontendHttpRedirect.frontendListenerName}'
    }
  }
}]

module pid_cuaId '.bicep/nested_cuaId.bicep' = if (!empty(cuaId)) {
  name: 'pid-${cuaId}'
  params: {}
}

resource applicationGateway 'Microsoft.Network/applicationGateways@2021-02-01' = {
  name: applicationGatewayName
  location: location
  identity: (empty(managedIdentityResourceId) ? json('null') : identity)
  tags: tags
  properties: {
    sku: {
      name: sku
      tier: (endsWith(sku, 'v2') ? sku : substring(sku, 0, indexOf(sku, '_')))
      capacity: capacity
    }
    gatewayIPConfigurations: [
      {
        name: gatewayIpConfigurationName
        properties: {
          subnet: {
            id: subnetResourceId
          }
        }
      }
    ]
    frontendIPConfigurations: [
      {
        name: frontendPrivateIPConfigurationName
        type: 'Microsoft.Network/applicationGateways/frontendIPConfigurations'
        properties: (empty(frontendPrivateIpAddress) ? frontendPrivateIPDynamicConfiguration : frontendPrivateIPStaticConfiguration)
      }
      {
        name: frontendPublicIPConfigurationName
        properties: {
          publicIPAddress: {
            id: frontendPublicIpResourceId
          }
        }
      }
    ]
    sslCertificates: (empty(sslCertificateKeyVaultSecretId) ? json('null') : sslCertificates)
    backendAddressPools: backendAddressPools
    probes: probes_var
    backendHttpSettingsCollection: backendHttpConfigurations_var
    frontendPorts: frontendPorts
    httpListeners: httpListeners
    redirectConfigurations: redirectConfigurations
    requestRoutingRules: requestRoutingRules
    enableHttp2: http2Enabled
    webApplicationFirewallConfiguration: (startsWith(sku, 'WAF') ? wafConfiguration : json('null'))
  }
  dependsOn: []
}

resource applicationGateway_lock 'Microsoft.Authorization/locks@2016-09-01' = if (lock != 'NotSpecified') {
  name: '${applicationGateway.name}-${lock}-lock'
  properties: {
    level: lock
    notes: (lock == 'CanNotDelete') ? 'Cannot delete resource or child resources.' : 'Cannot modify the resource or child resources.'
  }
  scope: applicationGateway
}

resource applicationGateway_diagnosticSettingName 'Microsoft.Insights/diagnosticsettings@2017-05-01-preview' = if ((!empty(diagnosticStorageAccountId)) || (!empty(workspaceId)) || (!empty(eventHubAuthorizationRuleId)) || (!empty(eventHubName))) {
  name: '${applicationGateway.name}-diagnosticSettings'
  properties: {
    storageAccountId: (empty(diagnosticStorageAccountId) ? json('null') : diagnosticStorageAccountId)
    workspaceId: (empty(workspaceId) ? json('null') : workspaceId)
    eventHubAuthorizationRuleId: (empty(eventHubAuthorizationRuleId) ? json('null') : eventHubAuthorizationRuleId)
    eventHubName: (empty(eventHubName) ? json('null') : eventHubName)
    metrics: ((empty(diagnosticStorageAccountId) && empty(workspaceId) && empty(eventHubAuthorizationRuleId) && empty(eventHubName)) ? json('null') : diagnosticsMetrics)
    logs: ((empty(diagnosticStorageAccountId) && empty(workspaceId) && empty(eventHubAuthorizationRuleId) && empty(eventHubName)) ? json('null') : diagnosticsLogs)
  }
  scope: applicationGateway
}

module applicationGateway_rbac '.bicep/nested_rbac.bicep' = [for (roleAssignment, index) in roleAssignments: {
  name: '${deployment().name}-rbac-${index}'
  params: {
    roleAssignmentObj: roleAssignment
    resourceName: applicationGateway.name
  }
}]

output applicationGatewayName string = applicationGateway.name
output applicationGatewayResourceId string = applicationGateway.id
output applicationGatewayResourceGroup string = resourceGroup().name
