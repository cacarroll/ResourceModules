<#
.SYNOPSIS
Run a template validation using a given parameter file

.DESCRIPTION
Run a template validation using a given parameter file
Works on a resource group, subscription, managementgroup and tenant level

.PARAMETER parametersBasePath
Mandatory. The path to the root of the parameters folder to test with

.PARAMETER templateFilePath
Mandatory. Path to the template file from root.

.PARAMETER parameterFilePath
Mandatory. Path to the parameter file from root.

.PARAMETER location
Mandatory. Location to test in. E.g. usgovvirginiana

.PARAMETER resourceGroupName
Optional. Name of the resource group to deploy into. Mandatory if deploying into a resource group (resource group level)

.PARAMETER subscriptionId
Optional. Id of the subscription to deploy into. Mandatory if deploying into a subscription (subscription level) using a Management groups service connection

.PARAMETER managementGroupId
Optional. Name of the management group to deploy into. Mandatory if deploying into a management group (management group level)

.EXAMPLE
Test-TemplateWithParameterFile templateFilePath 'ARM/KeyVault/deploy.json' -parameterFilePath 'ARM/KeyVault/.parameters/parameters.json' -location 'usgovvirginia' -resourceGroupName 'aLegendaryRg'

Test the deploy.json of the KeyVault module with the parameter file 'parameters.json' using the resource group 'aLegendaryRg' in location 'usgovvirginiana'

.EXAMPLE
Test-TemplateWithParameterFile templateFilePath 'ARM/ResourceGroup/deploy.json' -parameterFilePath 'ARM/ResourceGroup/.parameters/parameters.json' -location 'usgovvirginia'

Test the deploy.json of the ResourceGroup module with the parameter file 'parameters.json' in location 'usgovvirginiana'
#>
function Test-TemplateWithParameterFile {

    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory)]
        [string] $templateFilePath,

        [Parameter(Mandatory)]
        [string] $parameterFilePath,

        [Parameter(Mandatory)]
        [string] $location,

        [Parameter(Mandatory = $false)]
        [string] $resourceGroupName,

        [Parameter(Mandatory = $false)]
        [string] $subscriptionId,

        [Parameter(Mandatory = $false)]
        [string] $managementGroupId
    )

    begin {
        Write-Debug ('{0} entered' -f $MyInvocation.MyCommand)
    }

    process {

        $DeploymentInputs = @{
            TemplateFile          = $templateFilePath
            TemplateParameterFile = $parameterFilePath
            Verbose               = $true
            OutVariable           = 'ValidationErrors'
        }
        $ValidationErrors = $null

        ################################
        ## Determine deployment scope ##
        ################################
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
        switch ($deploymentScope) {
            'resourceGroup' {
                if (-not (Get-AzResourceGroup -Name $resourceGroupName -ErrorAction 'SilentlyContinue')) {
                    if ($PSCmdlet.ShouldProcess("Resource group [$resourceGroupName] in location [$location]", 'Create')) {
                        New-AzResourceGroup -Name $resourceGroupName -Location $location
                    }
                }
                if ($PSCmdlet.ShouldProcess('Resource group level deployment', 'Test')) {
                    $res = Test-AzResourceGroupDeployment @DeploymentInputs -ResourceGroupName $resourceGroupName
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
                if ($PSCmdlet.ShouldProcess('Subscription level deployment', 'Test')) {
                    $res = Test-AzSubscriptionDeployment @DeploymentInputs -Location $Location
                }
                break
            }
            'managementGroup' {
                if ($PSCmdlet.ShouldProcess('Management group level deployment', 'Test')) {
                    $res = Test-AzManagementGroupDeployment @DeploymentInputs -Location $Location -ManagementGroupId $ManagementGroupId
                }
                break
            }
            'tenant' {
                Write-Verbose 'Handling tenant level validation'
                if ($PSCmdlet.ShouldProcess('Tenant level deployment', 'Test')) {
                    $res = Test-AzTenantDeployment @DeploymentInputs -Location $location
                }
                break
            }
            default {
                throw "[$deploymentScope] is a non-supported template scope"
            }
        }
        if ($ValidationErrors) {
            Write-Warning ($res | ConvertTo-Json | Out-String)
            Write-Error 'Template is not valid.'
        }
    }

    end {
        Write-Debug ('{0} exited' -f $MyInvocation.MyCommand)
    }
}
