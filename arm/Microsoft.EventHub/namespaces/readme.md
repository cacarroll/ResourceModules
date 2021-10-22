# EventHub Namespaces `[Microsoft.EventHub/namespaces]`

This module deploys EventHub Namespace.

## Resource types

| Resource Type                                             | Api Version        |
| :-------------------------------------------------------- | :----------------- |
| `Microsoft.Authorization/locks`                           | 2016-09-01         |
| `Microsoft.EventHub/namespaces`                           | 2017-04-01         |
| `Microsoft.EventHub/namespaces/authorizationRules`        | 2017-04-01         |
| `Microsoft.EventHub/namespaces/disasterRecoveryConfigs`   | 2017-04-01         |
| `Microsoft.EventHub/namespaces/providers/roleAssignments` | 2021-04-01-preview |
| `Microsoft.Insights/diagnosticSettings`                   | 2017-05-01-preview |
| `Microsoft.Network/privateEndpoints`                      | 2021-05-01         |
| `Microsoft.Network/privateEndpoints/privateDnsZoneGroups` | 2020-05-01         |

## Parameters

| Parameter Name                  | Type   | Default Value                                                                                                                                      | Possible Values                                                                                                                                    | Description                                                                                                                                                                                                                                                                                                                                                                                                    |
| :------------------------------ | :----- | :------------------------------------------------------------------------------------------------------------------------------------------------- | :------------------------------------------------------------------------------------------------------------------------------------------------- | :------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `authorizationRules`            | array  | `[System.Collections.Hashtable]`                                                                                                                   |                                                                                                                                                    | Optional. Authorization Rules for the Event Hub namespace                                                                                                                                                                                                                                                                                                                                                      |
| `baseTime`                      | string | `[utcNow('u')]`                                                                                                                                    |                                                                                                                                                    | Generated. Do not provide a value! This date value is used to generate a SAS token to access the modules.                                                                                                                                                                                                                                                                                                      |
| `cuaId`                         | string |                                                                                                                                                    |                                                                                                                                                    | Optional. Customer Usage Attribution id (GUID). This GUID must be previously registered                                                                                                                                                                                                                                                                                                                        |
| `diagnosticLogsRetentionInDays` | int    | `365`                                                                                                                                              |                                                                                                                                                    | Optional. Specifies the number of days that logs will be kept for; a value of 0 will retain data indefinitely.                                                                                                                                                                                                                                                                                                 |
| `diagnosticStorageAccountId`    | string |                                                                                                                                                    |                                                                                                                                                    | Optional. Resource identifier of the Diagnostic Storage Account.                                                                                                                                                                                                                                                                                                                                               |
| `isAutoInflateEnabled`          | bool   |                                                                                                                                                    |                                                                                                                                                    | Optional. Switch to enable the Auto Inflate feature of Event Hub.                                                                                                                                                                                                                                                                                                                                              |
| `location`                      | string | `[resourceGroup().location]`                                                                                                                       |                                                                                                                                                    | Optional. Location for all resources.                                                                                                                                                                                                                                                                                                                                                                          |
| `lock`                          | string | `NotSpecified`                                                                                                                                     | `[CanNotDelete, NotSpecified, ReadOnly]`                                                                                                           | Optional. Specify the type of lock.                                                                                                                                                                                                                                                                                                                                                                            |
| `logsToEnable`                  | array  | `[ArchiveLogs, OperationalLogs, KafkaCoordinatorLogs, KafkaUserErrorLogs, EventHubVNetConnectionEvent, CustomerManagedKeyUserLogs, AutoScaleLogs]` | `[ArchiveLogs, OperationalLogs, KafkaCoordinatorLogs, KafkaUserErrorLogs, EventHubVNetConnectionEvent, CustomerManagedKeyUserLogs, AutoScaleLogs]` | Optional. The name of logs that will be streamed.                                                                                                                                                                                                                                                                                                                                                              |
| `maximumThroughputUnits`        | int    | `1`                                                                                                                                                |                                                                                                                                                    | Optional. Upper limit of throughput units when AutoInflate is enabled, value should be within 0 to 20 throughput units.                                                                                                                                                                                                                                                                                        |
| `metricsToEnable`               | array  | `[AllMetrics]`                                                                                                                                     | `[AllMetrics]`                                                                                                                                     | Optional. The name of metrics that will be streamed.                                                                                                                                                                                                                                                                                                                                                           |
| `namespaceAlias`                | string |                                                                                                                                                    |                                                                                                                                                    | Optional. The Disaster Recovery configuration name                                                                                                                                                                                                                                                                                                                                                             |
| `namespaceName`                 | string |                                                                                                                                                    |                                                                                                                                                    | Optional. The name of the EventHub namespace. If no name is provided, then unique name will be created.                                                                                                                                                                                                                                                                                                        |
| `networkAcls`                   | object | `{object}`                                                                                                                                         |                                                                                                                                                    | Optional. Service endpoint object information                                                                                                                                                                                                                                                                                                                                                                  |
| `partnerNamespaceId`            | string |                                                                                                                                                    |                                                                                                                                                    | Optional. ARM Id of the Primary/Secondary eventhub namespace name, which is part of GEO DR pairing                                                                                                                                                                                                                                                                                                             |
| `privateEndpoints`              | array  | `[]`                                                                                                                                               |                                                                                                                                                    | Optional. Configuration Details for private endpoints.                                                                                                                                                                                                                                                                                                                                                         |
| `roleAssignments`               | array  | `[]`                                                                                                                                               |                                                                                                                                                    | Optional. Array of role assignment objects that contain the 'roleDefinitionIdOrName' and 'principalId' to define RBAC role assignments on this resource. In the roleDefinitionIdOrName attribute, you can provide either the display name of the role definition, or its fully qualified ID in the following format: '/providers/Microsoft.Authorization/roleDefinitions/c2f4ef07-c644-48eb-af81-4b1b4947fb11' |
| `skuCapacity`                   | int    | `1`                                                                                                                                                |                                                                                                                                                    | Optional. Event Hub Plan scale-out capacity of the resource                                                                                                                                                                                                                                                                                                                                                    |
| `skuName`                       | string | `Standard`                                                                                                                                         | `[Basic, Standard]`                                                                                                                                | Optional. EventHub Plan sku name                                                                                                                                                                                                                                                                                                                                                                               |
| `tags`                          | object | `{object}`                                                                                                                                         |                                                                                                                                                    | Optional. Tags of the resource.                                                                                                                                                                                                                                                                                                                                                                                |
| `vNetId`                        | string |                                                                                                                                                    |                                                                                                                                                    | Optional. Virtual Network Id to lock down the Event Hub.                                                                                                                                                                                                                                                                                                                                                       |
| `workspaceId`                   | string |                                                                                                                                                    |                                                                                                                                                    | Optional. Resource identifier of Log Analytics.                                                                                                                                                                                                                                                                                                                                                                |
| `zoneRedundant`                 | bool   |                                                                                                                                                    |                                                                                                                                                    | Optional. Switch to make the Event Hub Namespace zone redundant.                                                                                                                                                                                                                                                                                                                                               |

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

### Parameter Usage: `authorizationRules`

Default value:

```json
"authorizationRules": {
    "value": [
        {
            "name": "RootManageSharedAccessKey",
            "properties": {
                "rights": [
                    "Listen",
                    "Manage",
                    "Send"
                ]
            }
        }
    ]
}
```

### Parameter Usage: `networkAcls`

```json
"networkAcls": {
    "value": {
        "bypass": "AzureServices",
        "defaultAction": "Deny",
        "virtualNetworkRules": [
            {
                "subnet": "sharedsvcs"
            }
        ],
        "ipRules": []
    }
}
```

### Parameter Usage: `vNetId`

```json
"vNetId": {
    "value": "/subscriptions/00000000/resourceGroups/resourceGroup"
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
            "service": "blob",
            "privateDnsZoneResourceIds": [ // Optional: No DNS record will be created if a private DNS zone Resource ID is not specified
                "/subscriptions/65c61e02-d55a-493f-9f4f-741a6cfc0c49/resourceGroups/validation-rg/providers/Microsoft.Network/privateDnsZones/privatelink.blob.core.usgovcloudapi.net"
            ],
            "customDnsConfigs": [ // Optional
                {
                    "fqdn": "customname.test.local",
                    "ipAddresses": [
                        "10.10.10.10"
                    ]
                }
            ]
        },
        // Example showing only mandatory fields
        {
            "subnetResourceId": "/subscriptions/65c61e02-d55a-493f-9f4f-741a6cfc0c49/resourceGroups/validation-rg/providers/Microsoft.Network/virtualNetworks/sxx-az-vnet-weu-x-001/subnets/sxx-az-subnet-weu-x-001",
            "service": "file"
        }
    ]
}
```

## Outputs

| Output Name                    | Type   |
| :----------------------------- | :----- |
| `namespace`                    | string |
| `namespaceConnectionString`    | string |
| `namespaceResourceGroup`       | string |
| `namespaceResourceId`          | string |
| `sharedAccessPolicyPrimaryKey` | string |

## Template references

- [Locks](https://docs.microsoft.com/en-us/azure/templates/Microsoft.Authorization/2016-09-01/locks)
- [Namespaces](https://docs.microsoft.com/en-us/azure/templates/Microsoft.EventHub/2017-04-01/namespaces)
- [Namespaces/Authorizationrules](https://docs.microsoft.com/en-us/azure/templates/Microsoft.EventHub/2017-04-01/namespaces/authorizationRules)
- [Namespaces/Disasterrecoveryconfigs](https://docs.microsoft.com/en-us/azure/templates/Microsoft.EventHub/2017-04-01/namespaces/disasterRecoveryConfigs)
- [Diagnosticsettings](https://docs.microsoft.com/en-us/azure/templates/Microsoft.Insights/2017-05-01-preview/diagnosticSettings)
- [Privateendpoints](https://docs.microsoft.com/en-us/azure/templates/Microsoft.Network/2021-05-01/privateEndpoints)
- [Privateendpoints/Privatednszonegroups](https://docs.microsoft.com/en-us/azure/templates/Microsoft.Network/2020-05-01/privateEndpoints/privateDnsZoneGroups)
