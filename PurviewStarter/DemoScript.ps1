param (
    [string]$TenantId,
    [string]$CatalogName,
    [string]$ResourcesLocation,
    [string]$CatalogResourceGroup,
    [string]$SubscriptionId,
    [string]$DatafactoryResourceGroup,
    [string]$DatafactoryAccountName,
    [string]$DatafactoryLocation = $ResourcesLocation,
    [switch]$ConnectToAzure = $false, 
    [switch]$CreateAdfAccountIfNotExists = $false,
    [switch]$UpdateAdfAccountTags = $false,
    [switch]$CreateAzureStorageAccount = $false,
    [string]$AzureStorageAccountName,
    [string]$AzureStorageResourceGroup,
    [string]$AzureStorageLocation = $ResourcesLocation,
    [switch]$CreateAzureStorageGen2Account = $false,
    [string]$AzureStorageGen2AccountName,
    [string]$AzureStorageGen2ResourceGroup,
    [string]$AzureStorageGen2Location = $ResourcesLocation,
    [switch]$GenerateDataForAzureStorage = $false,
    [switch]$GenerateDataForAzureStoragetemp = $false,
    [switch]$CopyDataFromAzureStorageToGen2 = $false,
    [string]$SqlUser,
    [string]$SqlPassword,
    [string]$SynapseWorkspaceName,
    [string]$SynapseResourceGroup,
    [string]$FileShareName = "raw",
    [string]$Region = $ResourcesLocation,
    [string]$RoleDef = "Storage Blob Data Contributor",
    [string]$KeyVaultName ,
    [string]$SynapseScope = "/subscriptions/$SubscriptionId/resourceGroups/$SynapseResourceGroup/providers/Microsoft.Storage/storageAccounts/$AzureStorageGen2AccountName"
)

$rootContainer = "starter1"

# Import Definition File variables 

. .\DefinitionFiles.ps1

##############################################################################
##
## Helper functions
##
##############################################################################

#
# Create the resource group if it doesn't exist.
function CreateResourceGroupIfNotExists (
    [string] $resourceGroupName, 
    [string] $resourceLocation) {
    $resourceGroup = Get-AzResourceGroup -Name $resourceGroupName `
        -ErrorAction SilentlyContinue
    if (!$resourceGroup) {
        New-AzResourceGroup -Name $resourceGroupName `
            -Location $resourceLocation
    }
}

#
# Update the existing Azure Data Factory V2 account with a tag to enable
# lineage information to the specified catalog.
#
function UpdateAzureDataFactoryV2 {
    $catalogEndpoint = "$CatalogName.catalog.purview.azure.com"
    CreateResourceGroupIfNotExists $DatafactoryResourceGroup $DatafactoryLocation
    try {
        $dataFactory = Get-AzDataFactoryV2 -Name $DatafactoryAccountName `
            -ResourceGroupName $DatafactoryResourceGroup `
            -ErrorAction SilentlyContinue

        if ($dataFactory) {
            Set-AzResource -ResourceId $dataFactory.DataFactoryId -Tag @{catalogUri = $catalogEndpoint } -Force
            Write-Host "Updated Azure Data Factory to emit lineage info to azure data factory $datafactoryAccountName to $catalogEndpoint"
        }
    }
    catch {
        if (!$_.Exception.Message.Contains("not found")) {
            throw "$datafactoryAccountName data factory does not exist"
        }
    }

    if (!$dataFactory) {
        if ($CreateAdfAccountIfNotExists -eq $true) {
            $dataFactory = Set-AzDataFactoryV2 -ResourceGroupName $datafactoryResourceGroup `
                -Location $DatafactoryLocation `
                -Name $DatafactoryAccountName `
                -Tag @{catalogUri = $catalogEndpoint }
        }
    }

    if ($dataFactory) {
        if (!$dataFactory.Identity) {
            Write-Output "Data Factory Identity not found, unable to update the catalog with the ADF managed identity"
        }
        else {
            return $dataFactory
        }
    }
    else {
        Write-Error "Unable to find, or create the ADF account"
    }
}

#
# Create a new Azure Storage Account / Gen2 account for the demo.
#
function New-AzureStorageDemoAccount (
    [switch][boolean] $EnableHierarchicalNamespace = $false,
    [string] $AccountName,
    [string] $ResourceGroup,
    [string] $Location) {
    CreateResourceGroupIfNotExists $AzureStorageResourceGroup $AzureStorageLocation
    try {
        $azureStorageAccount = Get-AzStorageAccount -Name $AccountName `
            -ResourceGroupName $ResourceGroup `
            -ErrorAction SilentlyContinue
        if (!$azureStorageAccount) {
            $gen2 = $false
            if ($EnableHierarchicalNamespace -eq $true) {
                $gen2 = $true
            }
            New-AzStorageAccount -Name $AccountName `
                -ResourceGroupName $ResourceGroup `
                -Location $Location `
                -SkuName Standard_LRS `
                -Kind StorageV2 `
                -EnableHierarchicalNamespace $gen2
        }

        if ($EnableHierarchicalNamespace -eq $true) {
            $accessKey = GetAzureStorageConnectionString -AccountName $AccountName -ResourceGroup $ResourceGroup -OnlyAccessKey
            .\AddContainer.ps1 -StorageAccountName $AccountName -FilesystemName $rootContainer -AccessKey $accessKey
        }
    }
    catch {
        Write-Output $_.Exception.Message
    }
}

#
# Get Storage Account connectionString
#
function GetAzureStorageConnectionString (
    [string] $AccountName,
    [string] $ResourceGroup,
    [switch] $OnlyAccessKey) {
    $azureStorageAccount = Get-AzStorageAccount -Name $AccountName `
        -ResourceGroupName $ResourceGroup `
        -ErrorAction SilentlyContinue
    if (!$azureStorageAccount) {
        throw "Azure Storage account $AccountName not found"
    }
    $accessKeys = Get-AzStorageAccountKey -ResourceGroupName $ResourceGroup `
        -Name $AccountName
    $accessKey = ($accessKeys | Where-Object { $_.KeyName -eq "key1" }).Value
    if ($OnlyAccessKey -eq $true) {
        return $accessKey
    }
    return "DefaultEndpointsProtocol=https;AccountName=$AccountName;AccountKey=$accessKey;EndpointSuffix=core.windows.net"
}

#
# Create the linked service
#
function CreateLinkedService (
    [string] $template,
    [string] $name,
    [string] $accountName,
    [string] $accessKey,
    [string] $dataFactoryName,
    [string] $resourceGroup) {
    Remove-Item "$name.json" -ErrorAction SilentlyContinue
    $linkedService = (($template -replace "<<name>>", "$name") -replace "<<account_key>>", "$accessKey") -replace "<<accountName>>", "$accountName"
    $linkedService | Out-File "$name.json"
    Set-AzDataFactoryV2LinkedService -DataFactoryName $dataFactoryName `
        -ResourceGroupName $resourceGroup `
        -Name $name `
        -DefinitionFile "$name.json" `
        -Force
    Remove-Item "$name.json" -ErrorAction SilentlyContinue
}

function CreateKeyVaultLinkedService (
    [string] $template,
    [string] $name,
    [string] $accountName,
    [string] $dataFactoryName,
    [string] $resourceGroup) {
    Remove-Item "$name.json" -ErrorAction SilentlyContinue
    $linkedService = (($template -replace "<<keyvaultlinkedservicename>>", "$name") -replace "<<keyvaultname>>", "$KeyVaultName") 
    $linkedService | Out-File "$name.json"
    Set-AzDataFactoryV2LinkedService -DataFactoryName $dataFactoryName `
        -ResourceGroupName $resourceGroup `
        -Name $name `
        -DefinitionFile "$name.json" `
        -Force
    Remove-Item "$name.json" -ErrorAction SilentlyContinue
}

function CreateSynapseLinkedService (
    [string] $template,
    [string] $name,
    [string] $dataFactoryName,
    [string] $resourceGroup,
    [string] $sqlPoolName) {
    Remove-Item "$name.json" -ErrorAction SilentlyContinue
    $linkedService = ((((($template -replace "<<name>>", "$SynapseWorkspaceName") -replace "<<keyvaultlinkedservicename>>", "azureKeyVaultLinkedService") -replace "<<secretname>>", "SQLPassword") -replace "<<poolname>>", $sqlPoolName) -replace "<<userid>>", $SqlUser) -replace "<<lsname>>", $name
    $linkedService | Out-File "$name.json"
    Set-AzDataFactoryV2LinkedService -DataFactoryName $dataFactoryName `
        -ResourceGroupName $resourceGroup `
        -Name $name `
        -DefinitionFile "$name.json" `
        -Force
    Remove-Item "$name.json" -ErrorAction SilentlyContinue
}

function CreatePipelineAndRunPipeline (
    [string] $pipelineTemplate,
    [string] $name,
    [string] $dataFactoryName,
    [string] $dataFactoryResourceGroup,
    [string] $azureStorageLinkedServiceDatasetName,
    [string] $azureStorageGen2LinkedServiceDatasetName) {
    $fileName = "pipeline-$name.json"
    Remove-Item $fileName -ErrorAction SilentlyContinue
    $template = (($pipelineTemplate -replace "<<name>>", $name) -replace "<<azureStorageLinkedServiceDataSet>>", $azureStorageLinkedServiceDatasetName) -replace "<<azureStorageGen2LinkedServiceDataSet>>", $azureStorageGen2LinkedServiceDatasetName
    $template | Out-File $fileName
    Set-AzDataFactoryV2Pipeline -Name $name `
        -DefinitionFile $fileName `
        -ResourceGroupName $dataFactoryResourceGroup `
        -DataFactoryName $dataFactoryName `
        -Force
    $runId = Invoke-AzDataFactoryV2Pipeline -ResourceGroupName $dataFactoryResourceGroup `
        -DataFactoryName $dataFactoryName `
        -PipelineName $name
    Write-Host "Executing Copy pipeline $runId"
    Remove-Item $fileName -ErrorAction SilentlyContinue
}

function CreateSynapsePipelineAndRunPipeline (
    [string] $pipelineTemplate,
    [string] $name,
    [string] $dataFactoryName,
    [string] $dataFactoryResourceGroup) {
    
    $fileName = "pipeline-$name.json"
    Remove-Item $fileName -ErrorAction SilentlyContinue
    
    $pipelineTemplate | Out-File $fileName
    
    Set-AzDataFactoryV2Pipeline -Name $name -ResourceGroupName $dataFactoryResourceGroup -DataFactoryName $dataFactoryName -DefinitionFile $fileName -Force
    
    $runId = Invoke-AzDataFactoryV2Pipeline -ResourceGroupName $dataFactoryResourceGroup -DataFactoryName $dataFactoryName -PipelineName $name
    
    Write-Host "Executing Copy pipeline $runId"
    Remove-Item $fileName -ErrorAction SilentlyContinue
}

function CreateMainPipelineAndRunPipeline (
    [string] $pipelineTemplate,
    [string] $name,
    [string] $dataFactoryName,
    [string] $dataFactoryResourceGroup) {
    
    $fileName = "pipeline-$name.json"
    Remove-Item $fileName -ErrorAction SilentlyContinue
    
    $pipelineTemplate | Out-File $fileName
    
    Set-AzDataFactoryV2Pipeline -Name $name -ResourceGroupName $dataFactoryResourceGroup -DataFactoryName $dataFactoryName -DefinitionFile $fileName -Force
    
    $runId = Invoke-AzDataFactoryV2Pipeline -ResourceGroupName $dataFactoryResourceGroup -DataFactoryName $dataFactoryName -PipelineName $name
    
    Write-Host "Executing Copy pipeline $runId"
    Remove-Item $fileName -ErrorAction SilentlyContinue
}

#
# Create the linked service
#
function CreateDataSet (
    [string] $dataSetName,
    [string] $linkedServiceReference,
    [string] $container,
    [string] $dataFactoryName,
    [string] $resourceGroup,
    [string] $template) {
    Remove-Item "$dataSetName.json" -ErrorAction SilentlyContinue
    $dataSet = (($template -replace "<<datasetName>>", "$dataSetName") -replace "<<linkedServiceName>>", "$linkedServiceReference") -replace "<<filesystemname>>", "$container"
    $dataSet | Out-File "$dataSetName.json"
    Set-AzDataFactoryV2Dataset -Name $dataSetName `
        -DefinitionFile "$dataSetName.json" `
        -Force `
        -DataFactoryName $dataFactoryName `
        -ResourceGroupName $resourceGroup
    Remove-Item "$dataSetName.json" -ErrorAction SilentlyContinue
}

function CreateADLSCSVDataSet (
    [string] $dataSetName,
    [string] $linkedServiceReference,
    [string] $dataFactoryName,
    [string] $resourceGroup,
    [string] $template) {
    Remove-Item "$dataSetName.json" -ErrorAction SilentlyContinue
    $dataSet = (($template -replace "<<datasetname>>", "$dataSetName") -replace "<<linkedServiceName>>", "$linkedServiceReference") 
    $dataSet | Out-File "$dataSetName.json"
    Set-AzDataFactoryV2Dataset -Name $dataSetName `
        -DefinitionFile "$dataSetName.json" `
        -Force `
        -DataFactoryName $dataFactoryName `
        -ResourceGroupName $resourceGroup
    Remove-Item "$dataSetName.json" -ErrorAction SilentlyContinue
}

function CreateSynapseDataSet (
    [string] $dataSetName,
    [string] $linkedServiceReference,
    [string] $dataFactoryName,
    [string] $resourceGroup,
    [string] $template) {
    
    $filename = "$dataSetName.json"
    Remove-Item $filename -ErrorAction SilentlyContinue
    
    $dataSet = ($template -replace "<<datasetName>>", "$dataSetName") -replace "<<linkedServiceName>>", "$linkedServiceReference"
    
    $dataSet | Out-File "$dataSetName.json"
    Set-AzDataFactoryV2Dataset -Name $dataSetName `
        -DefinitionFile $filename -Force -DataFactoryName $dataFactoryName -ResourceGroupName $resourceGroup
   
    Remove-Item $filename -ErrorAction SilentlyContinue
}

function Get-AzCachedAccessToken() {
    $ErrorActionPreference = 'Stop'
    #$azProfile = [Microsoft.Azure.Commands.Common.Authentication.Abstractions.AzureRmProfileProvider]::Instance.Profile
    #if(-not $azProfile.Accounts.Count) {
    #    Write-Error "Ensure you have logged in before calling this function."    
    #}
  
    #$currentAzureContext = Get-AzContext
    #$profileClient = New-Object Microsoft.Azure.Commands.ResourceManager.Common.RMProfileClient($azProfile)
    #Write-Debug ("Getting access token for tenant" + $currentAzureContext.Tenant.TenantId)
    #$token = $profileClient.AcquireAccessToken($currentAzureContext.Tenant.TenantId)
    #$token.AccessToken

    $context = [Microsoft.Azure.Commands.Common.Authentication.Abstractions.AzureRmProfileProvider]::Instance.Profile.DefaultContext
    [Microsoft.Azure.Commands.Common.Authentication.AzureSession]::Instance.AuthenticationFactory.Authenticate($context.Account, $context.Environment, $context.Tenant.Id.ToString(), $null, [Microsoft.Azure.Commands.Common.Authentication.ShowDialog]::Never, $null, "https://projectbabylon.azure.net").AccessToken
}

function Get-AzBearerToken() {
    $ErrorActionPreference = 'Stop'
    ('Bearer {0}' -f (Get-AzCachedAccessToken))
}

#
# Add the linked service to
#
function AddPurviewDataCuratorManagedIdentityToCatalog (
    [string] $servicePrincipalId,
    [string] $resourceName
) {
    Write-Output "subscriptionId:$subscriptionId catalogResourceGroup:$CatalogResourceGroup catalogName=$CatalogName"
    Write-Output "Giving $resourceName ($servicePrincipalId) Data Curator Access to Purview account $CatalogName"
    # Purview Data Curator
    $DataCuratorRoleId = "8a3c28859b384fd29d9991af537c1347"
    $FullPurviewAccountScope = "/subscriptions/$SubscriptionId/resourceGroups/$CatalogResourceGroup/providers/Microsoft.Purview/accounts/$CatalogName"
    New-AzRoleAssignment -ObjectId $servicePrincipalId -RoleDefinitionId $DataCuratorRoleId -Scope $FullPurviewAccountScope
}

function AddCatalogToStorageAccountsRole (
    [string] $servicePrincipalId,
    [string] $resourceName,
    [string] $storageAccountName, 
    [string] $storageScope
) {
    Write-Output "subscriptionId:$subscriptionId catalogResourceGroup:$CatalogResourceGroup catalogName=$CatalogName"

    Write-Output "Giving $resourceName ($servicePrincipalId) Storage Blob Data Reader Access to Storage account $storageAccountName"

    New-AzRoleAssignment -ObjectId $servicePrincipalId -RoleDefinitionName "Storage Blob Data Reader" -Scope $storageScope
}

function RoleAssignmentsToCatalog (
    [string] $servicePrincipalId,
    [string] $subscriptionId,
    [string] $resourceScope,
    [string] $roleId,
    [string] $catalogRGNameString,
    [string] $catalogNameString
) {
    New-AzRoleAssignment -ObjectId $servicePrincipalId -RoleDefinitionName "Owner" -ResourceName $catalogNameString -ResourceType "Microsoft.Purview/accounts" -ResourceGroupName $catalogRGNameString
}

##############################################################################
##
## main()
##
##############################################################################

##
## Check to see if we are going to create a demo azure storage account
##
if ($CreateAzureStorageAccount -eq $true) {
    if (!$AzureStorageAccountName) {
        throw "Azure Storage Name needs to be specified"
    }
    if (!$AzureStorageLocation) {
        throw "Azure Storage Location needs to be specified"
    }
    if (!$AzureStorageResourceGroup) {
        throw "Azure Storage Resource Group needs to be specified"
    }
    New-AzureStorageDemoAccount -AccountName $AzureStorageAccountName `
        -ResourceGroup $AzureStorageResourceGroup `
        -Location $AzureStorageLocation
}

Write-Output "Blob Storage Account Created"

New-AzResourceGroupDeployment -ResourceGroupName $ResourceGroup -TemplateFile ".\purviewtemplate_variables.json"

Write-Output "Purview Account Created"

##
## Check to see if we are going to update the ADF account
##
if ($UpdateAdfAccountTags -eq $true) {
    if (!$DatafactoryAccountName) {
        throw "Data Factory Account Name needs to be specified"
    }
    if (!$DatafactoryLocation) {
        throw "Data Factory Account Location needs to be specified"
    }
    if (!$DatafactoryResourceGroup) {
        throw "Data Factory Account Resource Group needs to be specified"
    }
    $createdDataFactory = UpdateAzureDataFactoryV2
}

Write-Output "Data Factory Account Created"

##
## Check to see if we are going to create a demo ADLS Gen2 account
##
if ($CreateAzureStorageGen2Account -eq $true) {
    if (!$AzureStorageGen2AccountName) {
        throw "Azure Storage Gen2 Name needs to be specified"
    }
    if (!$AzureStorageGen2Location) {
        throw "Azure Storage Gen2 Location needs to be specified"
    }
    if (!$AzureStorageGen2ResourceGroup) {
        throw "Azure Storage Gen2 Resource Group needs to be specified"
    }
    New-AzureStorageDemoAccount -AccountName $AzureStorageGen2AccountName `
        -ResourceGroup $AzureStorageGen2ResourceGroup `
        -Location $AzureStorageGen2Location `
        -EnableHierarchicalNamespace
}

Write-Output "ADLS Storage Account Created"

$ObjectIdpv = (Get-AzADServicePrincipal -SearchString $CatalogName).Id
Write-Output $ObjectIdpv

$usercontextAccountId = (Get-AzContext).account.id
Write-Output $usercontextAccountId

New-AzKeyVault -Name $KeyVaultName -ResourceGroupName $ResourceGroup -Location $ResourcesLocation
Set-AzKeyVaultAccessPolicy -VaultName $KeyVaultName -UserPrincipalName $usercontextAccountId -PermissionsToSecrets get, set, delete, list
Set-AzKeyVaultAccessPolicy -VaultName $KeyVaultName -ObjectId $ObjectIdpv -PermissionsToSecrets get, set, delete, list
$secretvalue = ConvertTo-SecureString $SqlPassword -AsPlainText -Force
Set-AzKeyVaultSecret -VaultName $KeyVaultName -Name "SQLPassword" -SecretValue $secretvalue

Write-Output "Key Vault Account Created"

## Synapse creation
$Cred = New-Object -TypeName System.Management.Automation.PSCredential ($SqlUser, (ConvertTo-SecureString $SqlPassword -AsPlainText -Force))

$WorkspaceParams = @{
    Name                              = $SynapseWorkspaceName
    ResourceGroupName                 = $SynapseResourceGroup
    DefaultDataLakeStorageAccountName = $AzureStorageGen2AccountName
    DefaultDataLakeStorageFilesystem  = $FileShareName
    SqlAdministratorLoginCredential   = $Cred
    Location                          = $Region
}

New-AzSynapseWorkspace @WorkspaceParams

$SynapseInfo = Get-AzSynapseWorkspace -ResourceGroupName $SynapseResourceGroup -Name $SynapseWorkspaceName


$RoleAssignmentParams = @{
    # SignInName = $SynapseWorkspaceName
    ObjectId           = $SynapseInfo.Identity.PrincipalId
    RoleDefinitionName = $RoleDef
    Scope              = $SynapseScope
}
New-AzRoleAssignment @RoleAssignmentParams

# To allow user access to the portal after resource creation
New-AzSynapseFirewallRule -WorkspaceName $SynapseWorkspaceName -Name "UserAccessFirewallRule" -StartIpAddress "0.0.0.0" -EndIpAddress "255.255.255.255"

$SQLPoolName = "SQLPool"
# Create SQL pool in Synapse workspace
New-AzSynapseSqlPool -WorkspaceName $SynapseWorkspaceName -Name  $SQLPoolName -PerformanceLevel DW100c

Write-Output "Synapse Workspace Account Created"

if (@(Get-AzureADUser -ObjectId $usercontextAccountId).Count -eq 0) {
    Write-Output "Log in timed out, please log in again."
    if(Get-Module -Name "AzureAD"){
        Connect-AzureAD
    } elseif (Get-Module -Name "AzureAD.Standard.Preview") {
        Write-Output "AzureAD.Standard.Preview Module is already imported. Follow Instructions to Connect."
        Connect-AzAccount -UseDeviceAuthentication
    }
}

$userADObjectId = (Get-AzureADUser -ObjectId $usercontextAccountId).ObjectId
# User access to resource group 
Write-output "Giving User Owner access over resource group."
New-AzRoleAssignment -ObjectId $userADObjectId -RoleDefinitionName "Owner" -ResourceGroupName $CatalogResourceGroup

# User owner access to Purview 
Write-Output "Setting the Managed Identity ($usercontextAccountId) $userADObjectId on the Catalog: $CatalogName"

$FullPurviewAccountScope2 = "/subscriptions/$subscriptionId/resourceGroups/$catalogResourceGroup/providers/Microsoft.Purview/accounts/$catalogName"

$PurviewRoleDefinitionName = "Owner"

RoleAssignmentsToCatalog -servicePrincipalId $userADObjectId ` -subscriptionId $SubscriptionId ` -resourceScope $FullPurviewAccountScope2 ` -roleId $PurviewRoleDefinitionName ` -catalogRGNameString $CatalogResourceGroup ` -catalogNameString $CatalogName

# Doing ADF role assignment here to prevent PrincipalId not found in directory error.
Write-Output "RoleAssignments in progress."
# ADF access to Purview
$dataFactoryPrincipalId = $createdDataFactory.Identity.PrincipalId
Set-AzKeyVaultAccessPolicy -VaultName $KeyVaultName -ObjectId $dataFactoryPrincipalId -PermissionsToSecrets get, set, delete, list

Write-Output "Setting the Managed Identity $dataFactoryPrincipalId on the Catalog: $CatalogName"
AddPurviewDataCuratorManagedIdentityToCatalog -servicePrincipalId $dataFactoryPrincipalId ` -resourceName $DatafactoryAccountName

# Synapse Analytics access to Purview
$synapsePrincipalId = $SynapseInfo.Identity.PrincipalId
Write-Output "Setting the Managed Identity $synapsePrincipalId on the Catalog: $CatalogName"
AddPurviewDataCuratorManagedIdentityToCatalog -servicePrincipalId $synapsePrincipalId ` -resourceName $SynapseWorkspaceName

# Purview Storage Blob Data Reader access to storage accounts
# blob store scoping URL
$blobStoreScope = "/subscriptions/$subscriptionId/resourceGroups/$CatalogResourceGroup/providers/Microsoft.Storage/storageAccounts/$AzureStorageAccountName"
AddCatalogToStorageAccountsRole -servicePrincipalId $ObjectIdpv ` -resourceName $CatalogName ` -StorageAccountName $AzureStorageAccountName ` -storageScope $blobStoreScope

# ADLS store scoping URL
$adlsStoreScope = "/subscriptions/$subscriptionId/resourceGroups/$CatalogResourceGroup/providers/Microsoft.Storage/storageAccounts/$AzureStorageGen2AccountName"
AddCatalogToStorageAccountsRole -servicePrincipalId $ObjectIdpv ` -resourceName $CatalogName ` -StorageAccountName $AzureStorageGen2AccountName ` -storageScope $adlsStoreScope

$azureStorageAccessKey = GetAzureStorageConnectionString -AccountName $AzureStorageAccountName `
    -ResourceGroup $AzureStorageResourceGroup `
    -OnlyAccessKey true
$storagecontext = New-AzStorageContext -StorageAccountName $AzureStorageAccountName -StorageAccountKey $azureStorageAccessKey

New-AzRmStorageContainer -ResourceGroupName $AzureStorageResourceGroup -AccountName $AzureStorageAccountName -ContainerName $rootContainer 

Get-ChildItem -Path ".\data_files\" -Recurse | Set-AzStorageBlobContent -Container $rootContainer -Context $storagecontext 

$azureStorageConnectionString = GetAzureStorageConnectionString -AccountName $AzureStorageAccountName `
    -ResourceGroup $AzureStorageResourceGroup
$azureStorageGen2ConnectionString = GetAzureStorageConnectionString -AccountName $AzureStorageGen2AccountName `
    -ResourceGroup $AzureStorageGen2ResourceGroup `
    -OnlyAccessKey

# Create the linked Services
# TODO: remove hard-coded linkedService and dataset names
CreateLinkedService -template $storageLinkedServiceDefinition `
    -name azureStorageLinkedService `
    -accessKey $azureStorageConnectionString `
    -dataFactoryName $DatafactoryAccountName `
    -resourceGroup $DatafactoryResourceGroup `
    -accountName $AzureStorageAccountName
CreateDataSet -dataSetName azureStorageLinkedServiceDataSet `
    -linkedServiceReference azureStorageLinkedService `
    -container $rootContainer `
    -dataFactoryName $DatafactoryAccountName `
    -resourceGroup $DatafactoryResourceGroup `
    -template $azureStorageBlobDataSet
    
# Create the datasets we'll copy from to
CreateLinkedService -template $storageGen2LinkedServiceDefinition `
    -name azureStorageGen2LinkedService `
    -accessKey $azureStorageGen2ConnectionString `
    -dataFactoryName $DatafactoryAccountName `
    -resourceGroup $DatafactoryResourceGroup `
    -accountName $AzureStorageGen2AccountName
CreateDataSet -dataSetName azureStorageGen2LinkedServiceDataSet `
    -linkedServiceReference azureStorageGen2LinkedService `
    -container $rootContainer `
    -dataFactoryName $DatafactoryAccountName `
    -resourceGroup $DatafactoryResourceGroup `
    -template $azureStorageGen2DataSet

### ADF FROM ADLS TO SYNAPSE

# Create Key Vault Linked Service
CreateKeyVaultLinkedService -template $keyVaultLinkedServiceDefinitions `
    -name azureKeyVaultLinkedService `
    -dataFactoryName $DatafactoryAccountName `
    -resourceGroup $DatafactoryResourceGroup `
    -accountName $AzureStorageAccountName

# Create Synapse Analytics Linked Service
CreateSynapseLinkedService -template $synapseLinkedServiceDefinitions `
    -name azureSynapseLinkedService `
    -dataFactoryName $DatafactoryAccountName `
    -resourceGroup $DatafactoryResourceGroup `
    -sqlPoolName $SQLPoolName

#  CREATE TABLE IN SYNAPSE SQL POOL
Write-Output "CREATE TABLE [dbo].[CustomerAddress]  ( id int NULL, street_address VARCHAR(255) NULL, country VARCHAR(255) NULL, postcode VARCHAR(255) NULL ) WITH ( DISTRIBUTION = HASH (id), CLUSTERED COLUMNSTORE INDEX )"

Invoke-Sqlcmd -Query "CREATE TABLE [dbo].[CustomerAddress]  ( id int NULL, street_address VARCHAR(255) NULL, country VARCHAR(255) NULL, postcode VARCHAR(255) NULL ) WITH ( DISTRIBUTION = HASH (id), CLUSTERED COLUMNSTORE INDEX )" -ServerInstance "$SynapseWorkspaceName.sql.azuresynapse.net" -Database $SQLPoolName -Username $SqlUser -Password $SqlPassword

Write-Output "CREATE TABLE [dbo].[CustomerInfo]  ( id int NULL, first_name VARCHAR(255) NULL, last_name VARCHAR(255) NULL, email VARCHAR(255) NULL, gender VARCHAR(255) NULL, ip_address VARCHAR(255) NULL ) WITH ( DISTRIBUTION = HASH (id), CLUSTERED COLUMNSTORE INDEX )"

Invoke-Sqlcmd -Query "CREATE TABLE [dbo].[CustomerInfo]  ( id int NULL, first_name VARCHAR(255) NULL, last_name VARCHAR(255) NULL, email VARCHAR(255) NULL, gender VARCHAR(255) NULL, ip_address VARCHAR(255) NULL ) WITH ( DISTRIBUTION = HASH (id), CLUSTERED COLUMNSTORE INDEX )" -ServerInstance "$SynapseWorkspaceName.sql.azuresynapse.net" -Database $SQLPoolName -Username $SqlUser -Password $SqlPassword

Write-Output "CREATE TABLE [dbo].[CreditCardInfo]  ( id int NULL, creditcardno VARCHAR(255) NULL, ccardtype VARCHAR(255) NULL, ccardcountry VARCHAR(255) NULL ) WITH ( DISTRIBUTION = HASH (id), CLUSTERED COLUMNSTORE INDEX )" 

Invoke-Sqlcmd -Query "CREATE TABLE [dbo].[CreditCardInfo]  ( id int NULL, creditcardno VARCHAR(255) NULL, ccardtype VARCHAR(255) NULL, ccardcountry VARCHAR(255) NULL ) WITH ( DISTRIBUTION = HASH (id), CLUSTERED COLUMNSTORE INDEX )" -ServerInstance "$SynapseWorkspaceName.sql.azuresynapse.net" -Database $SQLPoolName -Username $SqlUser -Password $SqlPassword

CreateADLSCSVDataSet -dataSetName azureADLSCSVCustomerDataLinkedServiceDataSet `
    -linkedServiceReference azureStorageGen2LinkedService `
    -dataFactoryName $DatafactoryAccountName `
    -resourceGroup $DatafactoryResourceGroup `
    -template $ADLSCSVCustomerData

CreateADLSCSVDataSet -dataSetName azureADLSCSVCustomerAddressLinkedServiceDataSet `
    -linkedServiceReference azureStorageGen2LinkedService `
    -dataFactoryName $DatafactoryAccountName `
    -resourceGroup $DatafactoryResourceGroup `
    -template $ADLSCSVCustomerAddress

CreateADLSCSVDataSet -dataSetName azureADLSCSVCreditCardNoLinkedServiceDataSet `
    -linkedServiceReference azureStorageGen2LinkedService `
    -dataFactoryName $DatafactoryAccountName `
    -resourceGroup $DatafactoryResourceGroup `
    -template $ADLSCSVCreditCardNo

# CreateADLSCSVDataSet -dataSetName azureADLSCSVLinkedServiceDataSet `
#     -linkedServiceReference azureStorageGen2LinkedService `
#     -dataFactoryName $DatafactoryAccountName `
#     -resourceGroup $DatafactoryResourceGroup `
#     -template $ADLSCSVDataSet

CreateSynapseDataSet -dataSetName azureSynapseCustInfoLinkedServiceDataSet `
    -linkedServiceReference azureSynapseLinkedService `
    -dataFactoryName $DatafactoryAccountName `
    -resourceGroup $DatafactoryResourceGroup `
    -template $SynapseDataSetCustInfo

CreateSynapseDataSet -dataSetName azureSynapseCustAddLinkedServiceDataSet `
    -linkedServiceReference azureSynapseLinkedService `
    -dataFactoryName $DatafactoryAccountName `
    -resourceGroup $DatafactoryResourceGroup `
    -template $SynapseCustomerAddressDataSet

CreateSynapseDataSet -dataSetName azureSynapseCredCardLinkedServiceDataSet `
    -linkedServiceReference azureSynapseLinkedService `
    -dataFactoryName $DatafactoryAccountName `
    -resourceGroup $DatafactoryResourceGroup `
    -template $SynapseCredCardDataset

Write-Output "Deploying pipeline"

# Create the Azure Data Factory Pipeline
CreateMainPipelineAndRunPipeline -pipelineTemplate $mainPipeline `
    -dataFactoryName $DatafactoryAccountName `
    -dataFactoryResourceGroup $DatafactoryResourceGroup `
    -azureSynapseLinkedServiceDatasetName "azureSynapseLinkedServiceDataSet" `
    -azureADLScsvLinkedServiceDatasetName "azureADLSCSVLinkedServiceDataSet" `
    -name "ADLSToSynapseCopyPipeline"

Write-Output "Blob to ADLS to Synapse pipeline deployment complete and triggered."

Write-Output "Deployment Completed."

Write-Output "Your resource group is called $CatalogResourceGroup"
Write-Output "Your SQL username is $SqlUser"
Write-Output "Your SQL password is $SqlPassword"