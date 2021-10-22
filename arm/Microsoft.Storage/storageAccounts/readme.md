# StorageAccounts `[Microsoft.Storage/storageAccounts]`

This module is used to deploy an Azure Storage Account, with resource lock and the ability to deploy 1 or more Blob Containers and 1 or more File Shares. Optional ACLs can be configured on the Storage Account and optional RBAC can be assigned on the Storage Account and on each Blob Container and File Share.

The default parameter values are based on the needs of deploying a diagnostic storage account.

## Resource types

| Resource Type                                                                         | Api Version        |
| :------------------------------------------------------------------------------------ | :----------------- |
| `Microsoft.Authorization/locks`                                                       | 2016-09-01         |
| `Microsoft.Network/privateEndpoints`                                                  | 2021-05-01         |
| `Microsoft.Network/privateEndpoints/privateDnsZoneGroups`                             | 2021-02-01         |
| `Microsoft.Storage/storageAccounts`                                                   | 2021-06-01         |
| `Microsoft.Storage/storageAccounts/blobServices`                                      | 2021-08-01         |
| `Microsoft.Storage/storageAccounts/blobServices/containers`                           | 2019-06-01         |
| `Microsoft.Storage/storageAccounts/blobServices/containers/immutabilityPolicies`      | 2019-06-01         |
| `Microsoft.Storage/storageAccounts/blobServices/containers/providers/roleAssignments` | 2021-04-01-preview |
| `Microsoft.Storage/storageAccounts/fileServices/fileshares/providers/roleAssignments` | 2021-04-01-preview |
| `Microsoft.Storage/storageAccounts/fileServices/shares`                               | 2019-06-01         |
| `Microsoft.Storage/storageAccounts/managementPolicies`                                | 2019-06-01         |
| `Microsoft.Storage/storageAccounts/providers/roleAssignments`                         | 2021-04-01-preview |
| `Microsoft.Storage/storageAccounts/queueServices/queues`                              | 2019-06-01         |
| `Microsoft.Storage/storageAccounts/queueServices/queues/providers/roleAssignments`    | 2021-04-01-preview |
| `Microsoft.Storage/storageAccounts/tableServices/tables`                              | 2019-06-01         |

## Parameters

| Parameter Name                          | Type   | Default Value                | Possible Values                                                                                                        | Description                                                                                                                                                                                                                                                                                                                                                                                                     |
| :-------------------------------------- | :----- | :--------------------------- | :--------------------------------------------------------------------------------------------------------------------- | :-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `allowBlobPublicAccess`                 | bool   | `True`                       |                                                                                                                        | Optional. Indicates whether public access is enabled for all blobs or containers in the storage account.                                                                                                                                                                                                                                                                                                        |
| `automaticSnapshotPolicyEnabled`        | bool   |                              |                                                                                                                        | Optional. Automatic Snapshot is enabled if set to true.                                                                                                                                                                                                                                                                                                                                                         |
| `azureFilesIdentityBasedAuthentication` | object | `{object}`                   |                                                                                                                        | Optional. Provides the identity based authentication settings for Azure Files.                                                                                                                                                                                                                                                                                                                                  |
| `basetime`                              | string | `[utcNow('u')]`              |                                                                                                                        | Generated. Do not provide a value! This date value is used to generate a SAS token to access the modules.                                                                                                                                                                                                                                                                                                       |
| `blobContainers`                        | array  | `[]`                         |                                                                                                                        | Optional. Blob containers to create.                                                                                                                                                                                                                                                                                                                                                                            |
| `cuaId`                                 | string |                              |                                                                                                                        | Optional. Customer Usage Attribution id (GUID). This GUID must be previously registered                                                                                                                                                                                                                                                                                                                         |
| `deleteBlobsAfter`                      | int    | `1096`                       |                                                                                                                        | Optional. Set up the amount of days after which the blobs will be deleted                                                                                                                                                                                                                                                                                                                                       |
| `deleteRetentionPolicy`                 | bool   | `True`                       |                                                                                                                        | Optional. Indicates whether DeleteRetentionPolicy is enabled for the Blob service.                                                                                                                                                                                                                                                                                                                              |
| `deleteRetentionPolicyDays`             | int    | `7`                          |                                                                                                                        | Optional. Indicates the number of days that the deleted blob should be retained. The minimum specified value can be 1 and the maximum value can be 365.                                                                                                                                                                                                                                                         |
| `enableArchiveAndDelete`                | bool   |                              |                                                                                                                        | Optional. If true, enables move to archive tier and auto-delete                                                                                                                                                                                                                                                                                                                                                 |
| `enableHierarchicalNamespace`           | bool   |                              |                                                                                                                        | Optional. If true, enables Hierarchical Namespace for the storage account                                                                                                                                                                                                                                                                                                                                       |
| `fileShares`                            | array  | `[]`                         |                                                                                                                        | Optional. File shares to create.                                                                                                                                                                                                                                                                                                                                                                                |
| `location`                              | string | `[resourceGroup().location]` |                                                                                                                        | Optional. Location for all resources.                                                                                                                                                                                                                                                                                                                                                                           |
| `lock`                                  | string | `NotSpecified`               | `[CanNotDelete, NotSpecified, ReadOnly]`                                                                               | Optional. Specify the type of lock.                                                                                                                                                                                                                                                                                                                                                                             |
| `managedServiceIdentity`                | string | `None`                       | `[None, SystemAssigned, SystemAssigned,UserAssigned, UserAssigned]`                                                    | Optional. Type of managed service identity.                                                                                                                                                                                                                                                                                                                                                                     |
| `minimumTlsVersion`                     | string | `TLS1_2`                     | `[TLS1_0, TLS1_1, TLS1_2]`                                                                                             | Optional. Set the minimum TLS version on request to storage.                                                                                                                                                                                                                                                                                                                                                    |
| `moveToArchiveAfter`                    | int    | `30`                         |                                                                                                                        | Optional. Set up the amount of days after which the blobs will be moved to archive tier                                                                                                                                                                                                                                                                                                                         |
| `networkAcls`                           | object | `{object}`                   |                                                                                                                        | Optional. Networks ACLs, this value contains IPs to whitelist and/or Subnet information.                                                                                                                                                                                                                                                                                                                        |
| `privateEndpoints`                      | array  | `[]`                         |                                                                                                                        | Optional. Configuration Details for private endpoints.                                                                                                                                                                                                                                                                                                                                                          |
| `queues`                                | array  | `[]`                         |                                                                                                                        | Optional. Queues to create.                                                                                                                                                                                                                                                                                                                                                                                     |
| `roleAssignments`                       | array  | `[]`                         |                                                                                                                        | Optional. Array of role assignment objects that contain the 'roleDefinitionIdOrName' and 'principalId' to define RBAC role assignments on this resource. In the roleDefinitionIdOrName attribute, you can provide either the display name of the role definition, or it's fully qualified ID in the following format: '/providers/Microsoft.Authorization/roleDefinitions/c2f4ef07-c644-48eb-af81-4b1b4947fb11' |
| `storageAccountAccessTier`              | string | `Hot`                        | `[Hot, Cool]`                                                                                                          | Optional. Storage Account Access Tier.                                                                                                                                                                                                                                                                                                                                                                          |
| `storageAccountKind`                    | string | `StorageV2`                  | `[Storage, StorageV2, BlobStorage, FileStorage, BlockBlobStorage]`                                                     | Optional. Type of Storage Account to create.                                                                                                                                                                                                                                                                                                                                                                    |
| `storageAccountName`                    | string |                              |                                                                                                                        | Required. Name of the Storage Account.                                                                                                                                                                                                                                                                                                                                                                          |
| `storageAccountSku`                     | string | `Standard_GRS`               | `[Standard_LRS, Standard_GRS, Standard_RAGRS, Standard_ZRS, Premium_LRS, Premium_ZRS, Standard_GZRS, Standard_RAGZRS]` | Optional. Storage Account Sku Name.                                                                                                                                                                                                                                                                                                                                                                             |
| `tables`                                | array  | `[]`                         |                                                                                                                        | Optional. Tables to create.                                                                                                                                                                                                                                                                                                                                                                                     |
| `tags`                                  | object | `{object}`                   |                                                                                                                        | Optional. Tags of the resource.                                                                                                                                                                                                                                                                                                                                                                                 |
| `userAssignedIdentities`                | object | `{object}`                   |                                                                                                                        | Optional. Mandatory 'managedServiceIdentity' contains UserAssigned. The identy to assign to the resource.                                                                                                                                                                                                                                                                                                       |
| `vNetId`                                | string |                              |                                                                                                                        | Optional. Virtual Network Identifier used to create a service endpoint.                                                                                                                                                                                                                                                                                                                                         |

### Parameter Usage: `roleAssignments`

```json
"roleAssignments": {
    "value": [
        {
            "roleDefinitionIdOrName": "Storage File Data SMB Share Contributor",
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

### Parameter Usage: `blobContainers`

The `blobContainer` parameter accepts a JSON Array of object with "name" and "publicAccess" properties in each to specify the name of the Blob Containers to create and level of public access (container level, blob level or none). Also RBAC can be assigned at Blob Container level

Here's an example of specifying two Blob Containes. The first named "one" with public access set at container level and RBAC Reader role assigned to two principal Ids. The second named "two" with no public access level and no RBAC role assigned.

```json
"blobContainers": {
    "value": [
        {
            "name": "one",
            "publicAccess": "Container", //Container, Blob, None
            "roleAssignments": [
                {
                    "roleDefinitionIdOrName": "Reader",
                    "principalIds": [
                        "12345678-1234-1234-1234-123456789012", // object 1
                        "78945612-1234-1234-1234-123456789012" // object 2
                    ]
                },
        {
            "name": "two",
            "publicAccess": "None", //Container, Blob, None
            "roleAssignments": [],
            "enableWORM": true,
            "WORMRetention": 200,
            "allowProtectedAppendWrites": false
        }
    ]
```

### Parameter Usage: `fileShares`

The `fileShares` parameter accepts a JSON Array of object with "name" and "shareQuota" properties in each to specify the name of the File Shares to create and the maximum size of the shares, in gigabytes. Also RBAC can be assigned at File Share level.

Here's an example of specifying a single File Share named "avdprofiles" with 5TB (5120GB) of shareQuota and Reader role assigned to two principal Ids.

```json
"fileShares": {
    "value": [
        {
            "name": "avdprofiles",
            "shareQuota": "5120",
            "roleAssignments": [
                {
                    "roleDefinitionIdOrName": "Reader",
                    "principalIds": [
                        "12345678-1234-1234-1234-123456789012", // object 1
                        "78945612-1234-1234-1234-123456789012" // object 2
                    ]
                }
            ]
        }
    ]
}
```

### Parameter Usage: `queues`

The `queues` parameter accepts a JSON Array of object with "name" and "metadata" properties in each to specify the name of the queue to create and its metadata, as a name-value pair. Also RBAC can be assigned at queue level.

Here's an example of specifying a single qeue named "queue1" with no metadata and Reader role assigned to two principal Ids.

```json
"queues": {
    "value": [
        {
            "name": "queue1",
            "metadata": {},
            "roleAssignments": [
                {
                    "roleDefinitionIdOrName": "Reader",
                    "principalIds": [
                        "12345678-1234-1234-1234-123456789012", // object 1
                        "78945612-1234-1234-1234-123456789012" // object 2
                    ]
                }
            ]
        }
    ]
}
```

### Parameter Usage: `tables`

The tables to be created in the storage account

```json
"tables": {
    "value": [
        "table1",
        "table2"
    ]
},
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

| Output Name                         | Type   |
| :---------------------------------- | :----- |
| `assignedIdentityID`                | string |
| `blobContainers`                    | array  |
| `fileShares`                        | array  |
| `queues`                            | array  |
| `storageAccountName`                | string |
| `storageAccountPrimaryBlobEndpoint` | string |
| `storageAccountRegion`              | string |
| `storageAccountResourceGroup`       | string |
| `storageAccountResourceId`          | string |
| `tables`                            | array  |

## Considerations

This is a generic module for deploying a Storage Account. Any customization for different storage needs (such as a diagnostic or other storage account) need to be done through the Archetype.
The hierarchical namespace of the storage account (see parameter `enableHierarchicalNamespace`), can be only set at creation time.

## Template references

- [Locks](https://docs.microsoft.com/en-us/azure/templates/Microsoft.Authorization/2016-09-01/locks)
- [Privateendpoints](https://docs.microsoft.com/en-us/azure/templates/Microsoft.Network/2021-05-01/privateEndpoints)
- [Privateendpoints/Privatednszonegroups](https://docs.microsoft.com/en-us/azure/templates/Microsoft.Network/2021-02-01/privateEndpoints/privateDnsZoneGroups)
- [Storageaccounts](https://docs.microsoft.com/en-us/azure/templates/Microsoft.Storage/2021-06-01/storageAccounts)
- [Storageaccounts/Blobservices](https://docs.microsoft.com/en-us/azure/templates/Microsoft.Storage/2021-08-01/storageAccounts/blobServices)
- [Storageaccounts/Blobservices/Containers](https://docs.microsoft.com/en-us/azure/templates/Microsoft.Storage/2019-06-01/storageAccounts/blobServices/containers)
- [Storageaccounts/Blobservices/Containers/Immutabilitypolicies](https://docs.microsoft.com/en-us/azure/templates/Microsoft.Storage/2019-06-01/storageAccounts/blobServices/containers/immutabilityPolicies)
- [Storageaccounts/Fileservices/Shares](https://docs.microsoft.com/en-us/azure/templates/Microsoft.Storage/2019-06-01/storageAccounts/fileServices/shares)
- [Storageaccounts/Managementpolicies](https://docs.microsoft.com/en-us/azure/templates/Microsoft.Storage/2019-06-01/storageAccounts/managementPolicies)
- [Storageaccounts/Queueservices/Queues](https://docs.microsoft.com/en-us/azure/templates/Microsoft.Storage/2019-06-01/storageAccounts/queueServices/queues)
- [Storageaccounts/Tableservices/Tables](https://docs.microsoft.com/en-us/azure/templates/Microsoft.Storage/2019-06-01/storageAccounts/tableServices/tables)
