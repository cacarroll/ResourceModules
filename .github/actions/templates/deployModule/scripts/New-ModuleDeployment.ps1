<#
.SYNOPSIS
Run a template deployment using a given parameter file

.DESCRIPTION
Run a template deployment using a given parameter file.
Works on a resource group, subscription, managementgroup and tenant level

.PARAMETER moduleName
Mandatory. The name of the module to deploy

.PARAMETER templateFilePath
Mandatory. The path to the deployment file

.PARAMETER parameterFilePath
Mandatory. Path to the parameter file from root. Can be a single file, multiple files, or directory that conains (.json) files.

.PARAMETER location
Mandatory. Location to test in. E.g. usgovvirginia

.PARAMETER resourceGroupName
Optional. Name of the resource group to deploy into. Mandatory if deploying into a resource group (resource group level)

.PARAMETER subscriptionId
Optional. Id of the subscription to deploy into. Mandatory if deploying into a subscription (subscription level) using a Management groups service connection

.PARAMETER managementGroupId
Optional. Name of the management group to deploy into. Mandatory if deploying into a management group (management group level)

.PARAMETER removeDeployment
Optional. Set to 'true' to add the tag 'removeModule = <ModuleName>' to the deployment. Is picked up by the removal stage to remove the resource again.

.PARAMETER additionalTags
Optional. Provde a Key Value Pair (Object) that will be appended to the Parameter file tags. Example: @{myKey = 'myValue',myKey2 = 'myValue2'}.

.PARAMETER retryLimit
Optional. Maximum retry limit if the deployment fails. Default is 3.

.EXAMPLE
New-ModuleDeployment -ModuleName 'KeyVault' -templateFilePath 'C:/KeyVault/deploy.json' -parameterFilePath 'C:/KeyVault/Parameters/parameters.json' -location 'usgovvirginia' -resourceGroupName 'aLegendaryRg'

Deploy the deploy.json of the KeyVault module with the parameter file 'parameters.json' using the resource group 'aLegendaryRg' in location 'usgovvirginia'

.EXAMPLE
New-ModuleDeployment -ModuleName 'KeyVault' -templateFilePath 'C:/ResourceGroup/deploy.json' -parameterFilePath 'C:/ResourceGroup/Parameters/parameters.json' -location 'usgovvirginia'

Deploy the deploy.json of the ResourceGroup module with the parameter file 'parameters.json' in location 'usgovvirginia'
#>
function New-ModuleDeployment {

    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory)]
        [string] $moduleName,

        [Parameter(Mandatory)]
        [string] $templateFilePath,

        [Parameter(Mandatory)]
        [string[]] $parameterFilePath,

        [Parameter(Mandatory)]
        [string] $location,

        [Parameter(Mandatory = $false)]
        [string] $resourceGroupName,

        [Parameter(Mandatory = $false)]
        [string] $subscriptionId,

        [Parameter(Mandatory = $false)]
        [string] $managementGroupId,

        [Parameter(Mandatory = $false)]
        [bool] $removeDeployment,

        [Parameter(Mandatory = $false)]
        [PSCustomObject]$additionalTags,

        [Parameter(Mandatory = $false)]
        [int]$retryLimit = 3
    )

    begin {
        Write-Debug ('{0} entered' -f $MyInvocation.MyCommand)
    }

    process {

        ## Assess Provided Parameter Path
        if ((Test-Path -Path $parameterFilePath -PathType Container) -and $parameterFilePath.Length -eq 1) {
            ## Transform Path to Files
            $parameterFilePath = Get-ChildItem $parameterFilePath -Recurse -Filter *.json | Select-Object -ExpandProperty FullName
            Write-Verbose "Detected Parameter File(s)/Directory - Count: `n $($parameterFilePath.Count)"
        }

        ## Iterate through each file
        foreach ($parameterFile in $parameterFilePath) {
            $fileProperties = Get-Item -Path $parameterFile
            Write-Verbose "Deploying: $($fileProperties.Name)"
            [bool]$Stoploop = $false
            [int]$retryCount = 1

            $DeploymentInputs = @{
                Name                  = "$moduleName-$(-join (Get-Date -Format yyyyMMddTHHMMssffffZ)[0..63])"
                TemplateFile          = $templateFilePath
                TemplateParameterFile = $parameterFile
                Verbose               = $true
                ErrorAction           = 'Stop'
            }

            ## Append Tags to Parameters if Resource supports them (all tags must be in one object)
            if ($removeDeployment -or $additionalTags) {

                # Parameter tags
                $parameterFileTags = (ConvertFrom-Json (Get-Content -Raw -Path $parameterFile) -AsHashtable).parameters.tags.value
                if ($parameterFileTags) { $parameterFileTags = @{} }

                # Pipeline tags
                if ($additionalTags) { $parameterFileTags += $additionalTags } # If additionalTags object is provided, append tag to the resource

                # Removal tags
                if ($removeDeployment) { $parameterFileTags += @{removeModule = $moduleName } } # If removeDeployment is set to true, append removeMoule tag to the resource
                # Overwrites parameter file tags parameter
                Write-Verbose ("removeDeployment for $moduleName= $removeDeployment `nadditionalTags:`n $($additionalTags | ConvertTo-Json)")
                $DeploymentInputs += @{Tags = $parameterFileTags }
            }

            if ((Split-Path $templateFilePath -Extension) -eq '.bicep') {
                # Bicep
                $bicepContent = Get-Content $templateFilePath
                $bicepScope = $bicepContent | Where-Object { $_ -like '*targetscope =*' }
                if (-not $bicepScope) {
                    $deploymentScope = 'resourceGroup'
                } else {
                    $deploymentScope = $bicepScope.ToLower().Replace('targetscope = ', '').Replace("'", '').Trim()
                }
            } else {
                # ARM
                $armSchema = (ConvertFrom-Json (Get-Content -Raw -Path $templateFilePath)).'$schema'
                switch -regex ($armSchema) {
                    '\/deploymentTemplate.json#$' { $deploymentScope = 'resourceGroup' }
                    '\/subscriptionDeploymentTemplate.json#$' { $deploymentScope = 'subscription' }
                    '\/managementGroupDeploymentTemplate.json#$' { $deploymentScope = 'managementGroup' }
                    '\/tenantDeploymentTemplate.json#$' { $deploymentScope = 'tenant' }
                    Default { throw "[$armSchema] is a non-supported ARM template schema" }
                }
            }

            #######################
            ## INVOKE DEPLOYMENT ##
            #######################
            do {
                try {
                    switch ($deploymentScope) {
                        'resourceGroup' {
                            if ($subscriptionId) {
                                $Context = Get-AzContext -ListAvailable | Where-Object Subscription -Match $subscriptionId
                                if ($Context) {
                                    $Context | Set-AzContext
                                }
                            }
                            if (-not (Get-AzResourceGroup -Name $resourceGroupName -ErrorAction 'SilentlyContinue')) {
                                if ($PSCmdlet.ShouldProcess("Resource group [$resourceGroupName] in location [$location]", 'Create')) {
                                    New-AzResourceGroup -Name $resourceGroupName -Location $location
                                }
                            }
                            if ($PSCmdlet.ShouldProcess('Resource group level deployment', 'Create')) {
                                $res = New-AzResourceGroupDeployment @DeploymentInputs -ResourceGroupName $resourceGroupName
                            }
                            break
                        }
                        'subscription' {
                            if ($subscriptionId) {
                                $Context = Get-AzContext -ListAvailable | Where-Object Subscription -Match $subscriptionId
                                if ($Context) {
                                    $Context | Set-AzContext
                                }
                            }
                            if ($PSCmdlet.ShouldProcess('Subscription level deployment', 'Create')) {
                                $res = New-AzSubscriptionDeployment @DeploymentInputs -Location $location
                            }
                            break
                        }
                        'managementGroup' {
                            if ($PSCmdlet.ShouldProcess('Management group level deployment', 'Create')) {
                                $res = New-AzManagementGroupDeployment @DeploymentInputs -Location $location -ManagementGroupId $managementGroupId
                            }
                            break
                        }
                        'tenant' {
                            if ($PSCmdlet.ShouldProcess('Tenant level deployment', 'Create')) {
                                $res = New-AzTenantDeployment @DeploymentInputs -Location $location
                            }
                            break
                        }
                        default {
                            throw "[$deploymentScope] is a non-supported template scope"
                            $Stoploop = $true
                        }
                    }
                    $Stoploop = $true
                } catch {
                    if ($retryCount -ge $retryLimit) {
                        throw $PSitem.Exception.Message
                        $Stoploop = $true
                    } else {
                        Write-Verbose "Resource deployment Failed.. ($retryCount/$retryLimit) Retrying in 5 Seconds.. `n"
                        Write-Verbose ($PSitem.Exception.Message | Out-String) -Verbose
                        Start-Sleep -Seconds 5
                        $retryCount++
                    }
                }
            }
            until ($Stoploop -eq $true -or $retryCount -gt $retryLimit)

            Write-Verbose 'Result' -Verbose
            Write-Verbose '------' -Verbose
            Write-Verbose ($res | Out-String) -Verbose
        }
    }

    end {
        Write-Debug ('{0} exited' -f $MyInvocation.MyCommand)
    }
}
