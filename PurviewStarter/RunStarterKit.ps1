param (
    [string]$CatalogName = $ResourceGroup + "pv",
    [string]$TenantId,
    [string]$SubscriptionId,
    [string]$ResourceGroup,
    [string]$CatalogResourceGroup = $ResourceGroup,
    [string]$StorageBlobName = $ResourceGroup + "adcblob",
    [string]$AdlsGen2Name = $ResourceGroup + "adcadls",
    [string]$DataFactoryName = $ResourceGroup + "adcfactory",
    [string]$KeyVaultName = $ResourceGroup + "kv",
    [switch]$ConnectToAzure = $false,
    [string]$SynapseWorkspaceName = $ResourceGroup + "synapsews"
)

### Install Az Powershell cmdlet module
if(-not (Get-InstalledModule -Name "Az")) {
    Write-Output Installing Az Module
    Start-Job -Name InstallAzModule -ScriptBlock { Install-Module -Name Az -Scope CurrentUser -Repository PSGallery -Force }
    Wait-Job -Name InstallAzModule
    Remove-Job -Name InstallAzModule
}

### Install Az.Accounts Powershell cmdlet module
if(-not (Get-Module Az.Accounts)) {
    Write-Output Installing Az.Accounts Module
    Start-Job -Name InstallAzAccounts -ScriptBlock { Import-Module Az.Accounts }
    Wait-Job -Name InstallAzAccounts
    Remove-Job -Name InstallAzAccounts
}


if (-not (Get-AzContext)) {
    Write-Output ConnectAzAccount
    Start-Job -Name ConnectToAzure -ScriptBlock { Connect-AzAccount }
    Wait-Job -Name ConnectToAzure
    Remove-Job -Name ConnectToAzure
    Get-AzContext
}

.\demoscript.ps1 -CreateAdfAccountIfNotExists `
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
                -TenantId $TenantId `
                -SubscriptionId $SubscriptionId `
                -AzureStorageResourceGroup $ResourceGroup `
                -AzureStorageGen2ResourceGroup $ResourceGroup `
                -CatalogResourceGroup $CatalogResourceGroup `
                -SynapseWorkspaceName $SynapseWorkspaceName `
                -KeyVaultName $KeyVaultName `
                -SynapseResourceGroup $ResourceGroup

