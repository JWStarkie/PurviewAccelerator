# PurviewDemo

## Need to figure out:

- how to store credentials/managed identity to synapse
- how to pass parameter down to nested scripts
- how to do one click deployment

## Things to do:

- add synapse, **done**
- add purview managed identity to synapse as db_owner/ or KV, **done**
- pass parameter of name and location down to TemplatePurview.Json, **done**
- add copy pipeline from gen2 to synapse (link synapse and adf using credentials/managed identity)
- add creator of resources to Purview IAM (Access Control)
- make location a parameter
- make one click deployment

## Purview Starter Kit Notes:

- Creates Blob storage and populates account with data
- Creates ADLS gen2
- Creates ADF and associates the instance to Purview
- Sets up and triggers a copy activity pipeline between the Blob storage and ADLS gen2 accounts
- Pushes the associated lineage from ADF to Purview

## Notes

- need to run the entire deployment script in PowerShell (run as administrator)

- Cloud file access denied error does cause issues with package installs. Currently registered as a bug with PowerShell package. Alternative way around this is to run individual Install-Module command direct in PowerShell.

- If issues running scripts on your machine and you get the following error:

`+ CategoryInfo : SecurityError: (:) [], PSSecurityException`
`+ FullyQualifiedErrorId : UnauthorizedAccess`

- Run following script to grant permissions:

- `Set-ExecutionPolicy -ExecutionPolicy UnRestricted -Scope CurrentUser`

When running in Powershell 7+ and if you also have Powersher 5.1 with AzureRM modules installed, you will running into some issues using this script:


Solution: Use: Import-Module AzureAD -UseWindowsPowerShell

Error:
Connect-AzureAD: C:\PurviewDemoHack\PurviewDemo\PurviewStarter\RunStarterKit.ps1:28
Line |
  28 |  Connect-AzureAD
     |  ~~~~~~~~~~~~~~~
     | One or more errors occurred. (Could not load type 'System.Security.Cryptography.SHA256Cng' from
     | assembly 'System.Core, Version=4.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089'.): Could not
     | load type 'System.Security.Cryptography.SHA256Cng' from assembly 'System.Core, Version=4.0.0.0,
     | Culture=neutral, PublicKeyToken=b77a5c561934e089'.

Connect-AzureAD: C:\PurviewDemoHack\PurviewDemo\PurviewStarter\RunStarterKit.ps1:28
Line |
  28 |  Connect-AzureAD
     |  ~~~~~~~~~~~~~~~
     | One or more errors occurred. (Could not load type 'System.Security.Cryptography.SHA256Cng' from
     | assembly 'System.Core, Version=4.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089'.)

Connect-AzureAD: C:\PurviewDemoHack\PurviewDemo\PurviewStarter\RunStarterKit.ps1:28
Line |
  28 |  Connect-AzureAD
     |  ~~~~~~~~~~~~~~~
     | Could not load type 'System.Security.Cryptography.SHA256Cng' from assembly 'System.Core,
     | Version=4.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089'.

Connect-AzureAD: C:\PurviewDemoHack\PurviewDemo\PurviewStarter\RunStarterKit.ps1:28
Line |
  28 |  Connect-AzureAD
     |  ~~~~~~~~~~~~~~~
     | One or more errors occurred. (Could not load type 'System.Security.Cryptography.SHA256Cng' from
     | assembly 'System.Core, Version=4.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089'.): Could not
     | load type 'System.Security.Cryptography.SHA256Cng' from assembly 'System.Core, Version=4.0.0.0,
     | Culture=neutral, PublicKeyToken=b77a5c561934e089'.
