# param (
#     [string]$ResourceGroup  = GenerateResourceGroupName -length 3,
#     [string]$CatalogName = $ResourceGroup + "pv",
#     [string]$CatalogResourceGroup = $ResourceGroup,
#     [string]$StorageBlobName = $ResourceGroup + "adcblob",
#     [string]$AdlsGen2Name = $ResourceGroup + "adcadls",
#     [string]$DataFactoryName = $ResourceGroup + "adcfactory",
#     [string]$KeyVaultName = $ResourceGroup + "kv",
#     [switch]$ConnectToAzure = $false,
#     [string]$SynapseWorkspaceName = $ResourceGroup + "synapsews"
# )

# Import helper functions script file
. .\HelperFunctions.ps1

[string]$ResourceGroup  = GenerateResourceGroupName -length 3
[string]$CatalogName = $ResourceGroup + "pv"
[string]$CatalogResourceGroup = $ResourceGroup
[string]$StorageBlobName = $ResourceGroup + "adcblob"
[string]$AdlsGen2Name = $ResourceGroup + "adcadls"
[string]$DataFactoryName = $ResourceGroup + "adcfactory"
[string]$KeyVaultName = $ResourceGroup + "kv"
[switch]$ConnectToAzure = $false
[string]$SynapseWorkspaceName = $ResourceGroup + "synapsews"
[string]$SqlUser = GenerateSQLString -base "admin"
[string]$SqlPassword = GenerateSQLString -base ""
[string[]]$PurviewLocations = @("Australia East", "Brazil South", "Canada Central", "Central India", "East US", "East US 2", "South Central US", "Southeast Asia", "UK South", "West Europe")

# ### Validation to make sure valid resource group name given before deployment process initiated. 
# if ($ResourceGroup -cmatch "[^a-z0-9]" -or ($ResourceGroup.Length) -gt 14 -or ($ResourceGroup.Length) -lt 4) {
#     Write-Error "$ResourceGroup is not a valid resource group name for this deployment package. It must be between 3 and 14 characters in length and use numbers and lower-case letters only. Please re-run the RunStarterKit.ps1 script with a valid -ResourceGroup name" -ErrorAction Stop
# }
# else {
#     Write-Output "Resource group name validation passed, continuing with deployment scripts!"
# }

# Allow users to authenticate to allow for AD to connect for the Service principle authentication used by Purview in KeyVault.
Write-Output "Connect to AzureAD"

Import-Module AzureAD 
Connect-AzureAD

Write-Output "After AD Connection"

### Install AzureAD Powershell cmdlet module
Write-Output "Checking for AzureAD Module."
if (-not (Get-InstalledModule -Name "AzureAD")) {
    InstallAzureADModule
}
else {
    Write-Output "AzureAD Module is already installed."
}

### Install Az Powershell cmdlet module
Write-Output "Checking for Az Module."
if (-not (Get-InstalledModule -Name "Az")) {
    InstallAZModule
}
else {
    Write-Output "Az Module is already installed."
}

### Install Az.Accounts Powershell cmdlet module
Write-Output "Checking for Az.Accounts Module."
if (-not (Get-InstalledModule Az.Accounts)) {
    InstallAZAccountsModule
}
else {
    Write-Output "Az.Accounts Module is already imported."
}

### Install Az.Synapse Powershell cmdlet module and Import
Write-Output "Checking for Az.Synapse Module."
if (-not (Get-InstalledModule Az.Synapse -MinimumVersion 0.12.0)) {
    InstallAZSynapseModule
    Import-Module  -Name Az.Synapse
}
else {
    Import-Module  -Name Az.Synapse
    Write-Output "Az.Synapse Module is already installed and Imported."
}

### Install SQLServer  Powershell cmdlet module
Write-Output "Checking for SQLServer Module."
if (-not (Get-InstalledModule -Name "SqlServer")) {
    InstallSqlServerModule
}
else {
    Write-Output "SqlServer Module is already installed."
}

### Connect to AzAccount if not connected - once authenticated, display selected subscription and confirm with user the selection.
# if (-not (Get-AzContext)) {
    ConnectAzAccount
# }
# else {
#     Get-AzContext
# }

### Confirmation validation for user to confirm subscription.
while ($finalres -ne 0) {
    $finalres = New-Menu -question "Do you wish to choose the Subscription selected above?"
    if ($finalres -eq 1) {
        #  Get-AzContext -ListAvailable
        Get-AzSubscription
        Write-Output "Please type the FULL and COMPLETE name of the subscription you would like to use:"
        $userInput = Read-Host
        Set-AzContext -SubscriptionName "$userInput"
    }
}

Write-Output "Subscription selection confirmed:"
$contextInfo = Get-AzContext
$contextSubscriptionId = $contextInfo.Subscription.Id
$contextTenantId = $contextInfo.Tenant.Id
Write-Output "Subscription Name" $contextInfo.Subscription.Name
Write-Output "Subscription ID: $contextSubscriptionId"
Write-Output "Tenant ID: $contextTenantId" 


### Confirmation validation for user to confirm location.
$chosenLocation = New-MenuLocation -question "Do you wish to choose the location selected above? Press enter to continue with default selection." -locations $PurviewLocations

$location = $PurviewLocations[$chosenLocation]

Write-Output "You have chosen $location as your resource location."

.\DemoScript.ps1 -CreateAdfAccountIfNotExists `
    -UpdateAdfAccountTags `
    -DatafactoryAccountName $DataFactoryName `
    -DatafactoryResourceGroup $ResourceGroup `
    -CatalogName $CatalogName `
    -GenerateDataForAzureStorage `
    -GenerateDataForAzureStoragetemp `
    -AzureStorageAccountName $StorageBlobName `
    -CreateAzureStorageAccount `
    -CreateAzureStorageGen2Account `
    -AzureStorageGen2AccountName $AdlsGen2Name `
    -CopyDataFromAzureStorageToGen2 `
    -TenantId $contextTenantId `
    -SubscriptionId $contextSubscriptionId `
    -AzureStorageResourceGroup $ResourceGroup `
    -AzureStorageGen2ResourceGroup $ResourceGroup `
    -CatalogResourceGroup $CatalogResourceGroup `
    -SynapseWorkspaceName $SynapseWorkspaceName `
    -KeyVaultName $KeyVaultName `
    -SynapseResourceGroup $ResourceGroup `
    -SqlUser $SqlUser `
    -SqlPassword $SqlPassword `
    -ResourcesLocation $location