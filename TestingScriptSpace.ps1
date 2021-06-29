# # Write-Output "Want this one? [Y] or [N]"
# # $Result = Read-Host


# # if (($Result -eq "Y") -or ($Result -eq "Yes")) {
# #     Write-Output "You said YES : $Result"
# # } elseif (($Result -eq "N") -or ($Result -eq "No")) {
# #     Write-Output "You said NO : $Result"
# # } else {
# #     Write-Output "Please enter either Yes [Y] or No [N] in your terminal."
# # }

# # using namespace System.Management.Automation.Host

# # function New-Menu ($question) {
    
# #     $title = "ACTION REQUIRED!"
    
# #     $yes = [ChoiceDescription]::new('&Yes', 'Yes you are happy')
# #     $no = [ChoiceDescription]::new('&No', 'No you would like to change')
    
# #     $options = [ChoiceDescription[]]($yes, $no)
    
# #     $result = $host.ui.PromptForChoice($Title, $question, $options, 0)
    
# #     switch ($result) {
# #         0 { 'Your answer is Yes' }
# #         1 { 'Your answer is No' }
# #     }
# #     return $result
# # }

# # $finalres = New-Menu -question 'What is your favorite color?'
# # Write-Output "Final result is $finalres"

# $subInfo = Get-AzSubscription
# Write-Output $subInfo.Name[0]
# Write-Output $subInfo.SubscriptionId[0]
# Write-Output $subInfo.TenantId[0]

# $contextInfo = Get-AzContext
# Write-Output "sub ID" $contextInfo.Subscription.Name
# Write-Output "ten ID" $contextInfo.Tenant.Id
