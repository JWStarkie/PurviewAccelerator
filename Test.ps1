# param (
#     [switch]$ConnectToAzure = $true
# )

# if ($ConnectToAzure -eq $true) {
#     Write-Output ConnectAzAccount
#     Start-Job -Name ConnectToAzure -ScriptBlock { Write-Output Connect-AzAccount }
#     Wait-Job -Name ConnectToAzure
#     Get-AzContext
# }
# Write-Output "Does this line work"

### Install Az.Accounts Powershell cmdlet module
#if(-not (Get-InstalledModule Az.Synapse)) {
#    Write-Output Installing Az.Synapse Module
#    Start-Job -Name InstallAzSynapse -ScriptBlock { Install-Module Az.Synapse }
#    Wait-Job -Name InstallAzSynapse
#}

# To get Tenant Id -  "tenantId": "[subscription().tenantId]",

# Added Import-Module AzureAD -UseWindowsPowerShell 
# added Connect-AzureAD -  need to automate this login.


param (
    [string]$ResourceGroup,
    [string]$KeyVaultName = $ResourceGroup + "kv",
    [string]$CatalogName = $ResourceGroup + "pv",
    [string]$ObjectIdpv = $(Get-AzureADServicePrincipal -Filter "DisplayName eq '$CatalogName'").ObjectId
)
Set-AzKeyVaultAccessPolicy -VaultName $KeyVaultName -ObjectId $ObjectIdpv -PermissionsToSecrets get,set,delete,list
$secret = Get-AzKeyVaultSecret -VaultName $KeyVaultName -Name "SQLPassword"
$ssPtr = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($secret.SecretValue)
try {
   $secretValueText = [System.Runtime.InteropServices.Marshal]::PtrToStringBSTR($ssPtr)
} finally {
   [System.Runtime.InteropServices.Marshal]::ZeroFreeBSTR($ssPtr)
}
Write-Output $secretValueText
