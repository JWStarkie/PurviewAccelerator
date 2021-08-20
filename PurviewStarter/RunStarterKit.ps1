$ErrorActionPreference = "Stop"

# Import helper functions script file
. .\HelperFunctions.ps1

[string]$ResourceGroup = GenerateResourceGroupName -length 3
[string]$CatalogName = $ResourceGroup + "pv"
[string]$CatalogResourceGroup = $ResourceGroup
[string]$StorageBlobName = $ResourceGroup + "adcblob"
[string]$AdlsGen2Name = $ResourceGroup + "adcadls"
[string]$DataFactoryName = $ResourceGroup + "adcfactory"
[string]$KeyVaultName = $ResourceGroup + "kv"
[string]$SynapseWorkspaceName = $ResourceGroup + "synapsews"
[string]$SqlUser = GenerateSQLString -base "admin"
[string]$SqlPassword = GenerateSQLString -base ""
[string[]]$PurviewLocations = @("Australia East", "Brazil South", "Canada Central", "Central India", "East US", "East US 2", "South Central US", "Southeast Asia", "UK South", "West Europe")

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

### Install AzureAD Powershell cmdlet module
Write-Output "Checking for AzureAD Module."
if (-not (Get-InstalledModule -Name "AzureAD")) {
    InstallAzureADModule
}
else {
    Write-Output "AzureAD Module is already installed."
}

# Allow users to authenticate to allow for AD to connect for the Service principle authentication used by Purview in KeyVault.

Write-Output "Check for AzureAD Module and Connect to AzureAD"
if (-not(Get-Module -Name "AzureAD.Standard.Preview")) {
    if (-not (Get-Module -Name "AzureAD")) {
        Import-Module AzureAD 
        ConnectAzAccount
        $connectedTenantId = (get-azcontext).subscription.tenantid
        Connect-AzureAD -TenantId "$connectedTenantId"
    }
    else {
        Write-Output "AzureAD Module is already imported. Follow Instructions to Connect."
        ConnectAzAccount
        $connectedTenantId = (get-azcontext).subscription.tenantid
        Connect-AzureAD -TenantId "$connectedTenantId"
    }
}
elseif (Get-Module -Name "AzureAD.Standard.Preview") {
    Write-Output "AzureAD.Standard.Preview Module is already imported. Follow Instructions to Connect."
    AzureAD.Standard.Preview\Connect-AzureAD
    Connect-AzAccount -UseDeviceAuthentication
}

### Confirmation validation for user to confirm subscription.
Get-AzContext
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
    -ResourcesLocation $location `
    -ResourceGroup $ResourceGroup