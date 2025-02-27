@description('Required. The name of the Alert.')
param alertName string

@description('Optional. Description of the alert.')
param alertDescription string = ''

@description('Optional. Location for all resources.')
param location string = 'global'

@description('Optional. Indicates whether this alert is enabled.')
param enabled bool = true

@description('Optional. The severity of the alert.')
@allowed([
  0
  1
  2
  3
  4
])
param severity int = 3

@description('Optional. how often the metric alert is evaluated represented in ISO 8601 duration format.')
@allowed([
  'PT1M'
  'PT5M'
  'PT15M'
  'PT30M'
  'PT1H'
])
param evaluationFrequency string = 'PT5M'

@description('Optional. the period of time (in ISO 8601 duration format) that is used to monitor alert activity based on the threshold.')
@allowed([
  'PT1M'
  'PT5M'
  'PT15M'
  'PT30M'
  'PT1H'
  'PT6H'
  'PT12H'
  'P1D'
])
param windowSize string = 'PT15M'

@description('Optional. the list of resource id\'s that this metric alert is scoped to.')
param scopes array = [
  subscription().id
]

@description('Optional. The resource type of the target resource(s) on which the alert is created/updated. Mandatory for MultipleResourceMultipleMetricCriteria.')
param targetResourceType string = ''

@description('Optional. The region of the target resource(s) on which the alert is created/updated. Mandatory for MultipleResourceMultipleMetricCriteria.')
param targetResourceRegion string = ''

@description('Optional. The flag that indicates whether the alert should be auto resolved or not.')
param autoMitigate bool = true

@description('Optional. The list of actions to take when alert triggers.')
param actions array = []

@description('Optional. Maps to the \'odata.type\' field. Specifies the type of the alert criteria.')
@allowed([
  'Microsoft.Azure.Monitor.SingleResourceMultipleMetricCriteria'
  'Microsoft.Azure.Monitor.MultipleResourceMultipleMetricCriteria'
  'Microsoft.Azure.Monitor.WebtestLocationAvailabilityCriteria'
])
param alertCriteriaType string = 'Microsoft.Azure.Monitor.MultipleResourceMultipleMetricCriteria'

@description('Required. Criterias to trigger the alert. Array of \'Microsoft.Azure.Monitor.SingleResourceMultipleMetricCriteria\' or \'Microsoft.Azure.Monitor.MultipleResourceMultipleMetricCriteria\' objects')
param criterias array

@description('Optional. Array of role assignment objects that contain the \'roleDefinitionIdOrName\' and \'principalId\' to define RBAC role assignments on this resource. In the roleDefinitionIdOrName attribute, you can provide either the display name of the role definition, or its fully qualified ID in the following format: \'/providers/Microsoft.Authorization/roleDefinitions/c2f4ef07-c644-48eb-af81-4b1b4947fb11\'')
param roleAssignments array = []

@description('Optional. Tags of the resource.')
param tags object = {}

@description('Optional. Customer Usage Attribution id (GUID). This GUID must be previously registered')
param cuaId string = ''

var actionGroups = [for action in actions: {
  actionGroupId: contains(action, 'actionGroupId') ? action.actionGroupId : action
  webHookProperties: contains(action, 'webHookProperties') ? action.webHookProperties : json('null')
}]

module pid_cuaId '.bicep/nested_cuaId.bicep' = if (!empty(cuaId)) {
  name: 'pid-${cuaId}'
  params: {}
}

resource metricAlert 'Microsoft.Insights/metricAlerts@2018-03-01' = {
  name: alertName
  location: location
  tags: tags
  properties: {
    description: alertDescription
    severity: severity
    enabled: enabled
    scopes: scopes
    evaluationFrequency: evaluationFrequency
    windowSize: windowSize
    targetResourceType: targetResourceType
    targetResourceRegion: targetResourceRegion
    criteria: {
      'odata.type': alertCriteriaType
      allOf: criterias
    }
    autoMitigate: autoMitigate
    actions: actionGroups
  }
}

module metricAlert_rbac '.bicep/nested_rbac.bicep' = [for (roleAssignment, index) in roleAssignments: {
  name: '${deployment().name}-rbac-${index}'
  params: {
    roleAssignmentObj: roleAssignment
    resourceName: metricAlert.name
  }
}]

output deploymentResourceGroup string = resourceGroup().name
output metricAlertName string = metricAlert.name
output metricAlertResourceId string = metricAlert.id
