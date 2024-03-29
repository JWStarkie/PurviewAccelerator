using namespace System.Management.Automation.Host

Function InstallAzureADModule () {
    Write-Output "Installing AzureAD Module. Please follow instructions on the pop-up window to complete this step."
    Install-Module -Name AzureAD -Scope CurrentUser -AllowClobber -Force
    Write-Output "AzureAD Module install complete."
}

Function InstallAZModule () {
    Write-Output "Installing Az Module. Please wait for completion notification."
    Install-Module -Name Az -Scope CurrentUser -AllowClobber -Force
    Write-Output "Az Module install complete."
}

Function InstallAZAccountsModule () {
    Write-Output "Installing Az.Accounts Module. Please wait for completion notification."
    Install-Module -Name Az.Accounts -Scope CurrentUser -AllowClobber -Force
    Write-Output "Az.Accounts Module install complete."
}

Function InstallSqlServerModule () {
    Write-Output "Installing SqlServer Module. Please wait for completion notification."
    Install-Module -Name SqlServer -Scope CurrentUser -Force
    Write-Output "SqlServer Module install complete."
}

Function InstallAZSynapseModule () {
    Write-Output "Installing Az.Synapse Module. Please wait for completion notification."
    Install-Module -Name Az.Synapse -Scope CurrentUser -Force
    Write-Output "Az.Synapse Module install complete."
}

Function ConnectAzAccount () {
    Write-Output "Connecting to Azure Account. Please follow instructions on the pop-up window to complete this step."
    Write-Output ConnectAzAccount
    Clear-AzContext -Scope CurrentUser -Force
    Connect-AzAccount
    Get-AzContext
    ### Confirmation validation for user to confirm tenant.
    while ($finalResult -ne 0) {
        $finalResult = New-Menu -question "Do you wish to choose the Tenant selected above?"
        if ($finalResult -eq 1) {
            Get-AzTenant
            Write-Output "Please copy and paste the ID of the Tenant you would like to use:"
            $userInput = Read-Host
            Connect-AzAccount -TenantId "$userInput"
            Get-AzTenant -TenantId "$userInput"
        }
    }
    Write-Output "Azure Account connected."
}

# Function to ask the user for input
Function New-Menu ($question) {
    $title = "ACTION REQUIRED!"
    $yes = [ChoiceDescription]::new('&Yes', 'Yes you are happy')
    $no = [ChoiceDescription]::new('&No', 'No you would like to change')
    $options = [ChoiceDescription[]]($yes, $no)
    $result = $host.ui.PromptForChoice($title, $question, $options, 0)
    return $result
}

Function New-MenuLocation ($question, $locations) {
    $options = @()
    $default = 0
    $index = 0 #Temporary - need to work out way of first character being different for all options
    foreach ($location in $locations) {
        $options += [ChoiceDescription]::new("&$index $location", "$location is the location")
        if ($location -eq "Brazil South") {
            $default = $index
        }
        $index = $index + 1
    }
    $title = "ACTION REQUIRED!"    
    $result = $host.ui.PromptForChoice($title, $question, $options, $default)
    return $result
}

#Function that generates random letters and numbers for the resource group name
Function GenerateResourceGroupName($length) {
    $random = "pdemo"
    $characters = @()
    for ($index = 0; $index -lt $length; $index++) {
        $characters += ( -join ((0..9) | Get-Random -Count 1))
        $characters += ( -join ((97..122) | Get-Random -Count 1 | ForEach-Object { [char]$_ }))
    }
    $characters = $characters | Sort-Object { Get-Random }
    $characters = -join $characters
    return $random + $characters
}

#Function that generates random letters and numbers
Function GenerateSQLString([string] $base) {
    $random = @()
    if ($base -eq "") {
        #SQL Password
        for ($index = 0; $index -lt 3; $index++) {
            $random += ((0..9) | Get-Random -Count 1)
            $random += ((65..90) | Get-Random -Count 1 | ForEach-Object { [char]$_ })
            $random += ((33, 35, 36, 37, 38) | Get-Random -Count 1 | ForEach-Object { [char]$_ })
            $random += ((97..122) | Get-Random -Count 1 | ForEach-Object { [char]$_ })
        }
        $random = $random | Sort-Object { Get-Random }
    }
    else {
        #SQL Username
        for ($index = 0; $index -lt 5; $index++) {
            $random += ( -join ((0..9) | Get-Random -Count 1))
        }
    }
    $random = -join $random
    return $base + $random
}
