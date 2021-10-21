# Machine Learning Services

This module deploys a Machine Learning Services Workspace.

## Resource types

| Resource Type                                                            | Api Version        |
| :----------------------------------------------------------------------- | :----------------- |
| `Microsoft.Authorization/locks`                                          | 2016-09-01         |
| `Microsoft.Insights/diagnosticSettings`                                  | 2017-05-01-preview |
| `Microsoft.MachineLearningServices/workspaces/providers/roleAssignments` | 2020-04-01-preview |
| `Microsoft.MachineLearningServices/workspaces`                           | 2021-04-01         |
| `Microsoft.Network/privateEndpoints/privateDnsZoneGroups`                | 2020-05-01         |
| `Microsoft.Network/privateEndpoints`                                     | 2020-05-01         |
| `Microsoft.Resources/deployments`                                        | 2019-10-01         |

## Parameters

| Parameter Name                            | Type   | Description                                                                                                                                                                                                                                                                                                                                                                                                    | DefaultValue               | Possible values                            |
| :---------------------------------------- | :----- | :------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | :------------------------- | :----------------------------------------- |
| `allowPublicAccessWhenBehindVnet`         | bool   | Optional. The flag to indicate whether to allow public access when behind VNet.                                                                                                                                                                                                                                                                                                                                | False                      |                                            |
| `associatedApplicationInsightsResourceId` | string | Required. The resource id of the associated Application Insights.                                                                                                                                                                                                                                                                                                                                              |                            |                                            |
| `associatedContainerRegistryResourceId`   | string | Optional. The resource id of the associated Container Registry.                                                                                                                                                                                                                                                                                                                                                |                            |                                            |
| `associatedKeyVaultResourceId`            | string | Required. The resource id of the associated Key Vault.                                                                                                                                                                                                                                                                                                                                                         |                            |                                            |
| `associatedStorageAccountResourceId`      | string | Required. The resource id of the associated Storage Account.                                                                                                                                                                                                                                                                                                                                                   |                            |                                            |
| `cuaId`                                   | string | Optional. Customer Usage Attribution id (GUID). This GUID must be previously registered                                                                                                                                                                                                                                                                                                                        |                            |                                            |
| `diagnosticLogsRetentionInDays`           | int    | Optional. Specifies the number of days that logs will be kept for; a value of 0 will retain data indefinitely.                                                                                                                                                                                                                                                                                                 | 365                        |                                            |
| `diagnosticSettingName`                   | string | Optional. The name of the Diagnostic setting.                                                                                                                                                                                                                                                                                                                                                                  | service                    |                                            |
| `diagnosticStorageAccountId`              | string | Optional. Resource identifier of the Diagnostic Storage Account.                                                                                                                                                                                                                                                                                                                                               |                            |                                            |
| `eventHubAuthorizationRuleId`             | string | Optional. Resource ID of the event hub authorization rule for the Event Hubs namespace in which the event hub should be created or streamed to.                                                                                                                                                                                                                                                                |                            |                                            |
| `eventHubName`                            | string | Optional. Name of the event hub within the namespace to which logs are streamed. Without this, an event hub is created for each log category.                                                                                                                                                                                                                                                                  |                            |                                            |
| `hbiWorkspace`                            | bool   | Optional. The flag to signal HBI data in the workspace and reduce diagnostic data collected by the service.                                                                                                                                                                                                                                                                                                    | False                      |                                            |
| `location`                                | string | Optional. Location for all resources.                                                                                                                                                                                                                                                                                                                                                                          | [resourceGroup().location] |                                            |
| `lock`                                    | string | Optional. Specify the type of lock.                                                                                                                                                                                                                                                                                                                                                                            | 'NotSpecified'             | 'CanNotDelete', 'NotSpecified', 'ReadOnly' |
| `privateEndpoints`                        | array  | Optional. Configuration Details for private endpoints.                                                                                                                                                                                                                                                                                                                                                         | System.Object[]            |                                            |
| `roleAssignments`                         | array  | Optional. Array of role assignment objects that contain the 'roleDefinitionIdOrName' and 'principalId' to define RBAC role assignments on this resource. In the roleDefinitionIdOrName attribute, you can provide either the display name of the role definition, or its fully qualified ID in the following format: '/providers/Microsoft.Authorization/roleDefinitions/c2f4ef07-c644-48eb-af81-4b1b4947fb11' | System.Object[]            |                                            |
| `sku`                                     | string | Required. Specifies the sku, also referred as 'edition' of the Azure Machine Learning workspace.                                                                                                                                                                                                                                                                                                               |                            | System.Object[]                            |
| `tags`                                    | object | Optional. Resource tags.                                                                                                                                                                                                                                                                                                                                                                                       |                            |                                            |
| `workspaceId`                             | string | Optional. Resource identifier of Log Analytics.                                                                                                                                                                                                                                                                                                                                                                |                            |                                            |
| `workspaceName`                           | string | Required. The name of the machine learning workspace.                                                                                                                                                                                                                                                                                                                                                          |                            |                                            |

### Parameter Usage: `roleAssignments`

```json
"roleAssignments": {
    "value": [
        {
            "roleDefinitionIdOrName": "Desktop Virtualization User",
            "principalIds": [
                "12345678-1234-1234-1234-123456789012", // object 1
                "78945612-1234-1234-1234-123456789012" // object 2
            ]
        },
        {
            "roleDefinitionIdOrName": "Reader",
            "principalIds": [
                "12345678-1234-1234-1234-123456789012", // object 1
                "78945612-1234-1234-1234-123456789012" // object 2
            ]
        },
        {
            "roleDefinitionIdOrName": "/providers/Microsoft.Authorization/roleDefinitions/c2f4ef07-c644-48eb-af81-4b1b4947fb11",
            "principalIds": [
                "12345678-1234-1234-1234-123456789012" // object 1
            ]
        }
    ]
}
```

### Parameter Usage: `tags`

Tag names and tag values can be provided as needed. A tag can be left without a value.

```json
"tags": {
    "value": {
        "Environment": "Non-Prod",
        "Contact": "test.user@testcompany.com",
        "PurchaseOrder": "1234",
        "CostCenter": "7890",
        "ServiceName": "DeploymentValidation",
        "Role": "DeploymentValidation"
    }
}
```

### Parameter Usage: `privateEndpoints`

To use Private Endpoint the following dependencies must be deployed:

- Destination subnet must be created with the following configuration option - `"privateEndpointNetworkPolicies": "Disabled"`.  Setting this option acknowledges that NSG rules are not applied to Private Endpoints (this capability is coming soon). A full example is available in the Virtual Network Module.

- Although not strictly required, it is highly recommened to first create a private DNS Zone to host Private Endpoint DNS records. See [Azure Private Endpoint DNS configuration](https://docs.microsoft.com/en-us/azure/private-link/private-endpoint-dns) for more information.

```json
"privateEndpoints": {
    "value": [
        // Example showing all available fields
        {
            "name": "sxx-az-sa-cac-y-123-pe", // Optional: Name will be automatically generated if one is not provided here
            "subnetResourceId": "/subscriptions/65c61e02-d55a-493f-9f4f-741a6cfc0c49/resourceGroups/validation-rg/providers/Microsoft.Network/virtualNetworks/sxx-az-vnet-weu-x-001/subnets/sxx-az-subnet-weu-x-001",
            "service": "amlworkspace",
            "privateDnsZoneResourceIds": [ // Optional: No DNS record will be created if a private DNS zone Resource ID is not specified
                "/subscriptions/xxx-xxx-xxx-xxx-xxx/resourcegroups/iacs/providers/Microsoft.Network/privateDnsZones/privatelink.api.azureml.ms",
                "/subscriptions/xxx-xxx-xxx-xxx-xxx/resourcegroups/iacs/providers/Microsoft.Network/privateDnsZones/privatelink.notebooks.azure.net"
            ],
            "customDnsConfigs": [ // Optional
                {
                    "fqdn": "customname.test.local",
                    "ipAddresses": [
                        "10.10.10.10"
                    ]
                }
            ]
        }
    ]
}
```

## Outputs

| Output Name                           | Type   | Description                                                                           |
| :------------------------------------ | :----- | :------------------------------------------------------------------------------------ |
| `machineLearningServiceResourceId`    | string | The Resource Id of the Machine Learning Service workspace.                            |
| `machineLearningServiceResourceGroup` | string | The name of the Resource Group the Machine Learning Service workspace was created in. |
| `machineLearningServiceName`          | string | The name of the Machine Learning Service workspace.                                   |

## Considerations

## Additional resources

- [What is Azure Machine Learning?](https://docs.microsoft.com/en-us/azure/machine-learning/overview-what-is-azure-ml)
- [Use tags to organize your Azure resources](https://docs.microsoft.com/en-us/azure/azure-resource-manager/resource-group-using-tags)- [Azure Resource Manager template reference](https://docs.microsoft.com/en-us/azure/templates/)
- [Workspaces](https://docs.microsoft.com/en-us/azure/templates/Microsoft.MachineLearningServices/2021-04-01/workspaces)
- [Locks](https://docs.microsoft.com/en-us/azure/templates/Microsoft.Authorization/2016-09-01/locks)
- [DiagnosticSettings](https://docs.microsoft.com/en-us/azure/templates/Microsoft.Insights/2017-05-01-preview/diagnosticSettings)
- [Deployments](https://docs.microsoft.com/en-us/azure/templates/Microsoft.Resources/2019-10-01/deployments)
