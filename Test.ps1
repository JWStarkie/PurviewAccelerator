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
if(-not (Get-InstalledModule Az.Synapse)) {
    Write-Output Installing Az.Synapse Module
    Start-Job -Name InstallAzSynapse -ScriptBlock { Install-Module Az.Synapse }
    Wait-Job -Name InstallAzSynapse
}