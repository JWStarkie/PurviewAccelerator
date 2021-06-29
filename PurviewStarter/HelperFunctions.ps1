using namespace System.Management.Automation.Host

Function InstallAzureADModule () {
    Write-Output "Installing AzureAD Module. Please follow instructions on the pop-up window to complete this step."
    Install-Module -Name AzureAD -Scope CurrentUser -Force
    Write-Output "AzureAD Module install complete."
}

Function InstallAZModule () {
    Write-Output "Installing Az Module. Please wait for completion notification."
    Install-Module -Name Az -Scope CurrentUse -Force
    Write-Output "Az Module install complete."
}

Function InstallAZAccountsModule () {
    Write-Output "Installing Az Module. Please wait for completion notification."
    Import-Module -Name Az.Accounts -Scope CurrentUse -Force
    Write-Output "Az Module install complete."
}

Function ConnectAzAccount () {
    Write-Output "Connecting to Azure Account. Please follow instructions on the pop-up window to complete this step."
    Write-Output ConnectAzAccount
    Connect-AzAccount
    Write-Output "Account connected. Azure Context:"
    Get-AzContext
}

# Function to ask the user for input
function New-Menu ($question) {
    
    $title = "ACTION REQUIRED!"
    
    $yes = [ChoiceDescription]::new('&Yes', 'Yes you are happy')
    $no = [ChoiceDescription]::new('&No', 'No you would like to change')
    
    $options = [ChoiceDescription[]]($yes, $no)
    
    $result = $host.ui.PromptForChoice($Title, $question, $options, 0)
    return $result
}