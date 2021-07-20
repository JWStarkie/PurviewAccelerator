# PurviewDemo

### Need to figure out:

- registering sources in Purview
- triggering scans
- upload glossary terms

### Things to do: [Projects Board](https://github.com/lipinght/PurviewDemo/projects/1)

- usage guide
- GitHub Clone Analytics
- PowerShell Usage Analytics
- REFACTORING!! 

### Things done:

- add synapse, **done**
- add purview managed identity to synapse as db_owner/ or KV, **done**
- pass parameter of name and location down to TemplatePurview.Json, **done**
- add copy pipeline from gen2 to synapse (link synapse and adf using credentials/managed identity) **done**
- add creator of resources to Purview IAM (Access Control) **done**
- make location a parameter **done**
- generate random resource group name **done**, SQL admin username and password **done**
  - print this in console at the end **done**

### Things we can't do:

- make new service principal for SQL pool access
  - https://docs.microsoft.com/en-gb/azure/azure-sql/database/authentication-aad-configure?tabs=azure-powershell#provision-azure-ad-admin-sql-database
- set active directory in SQL pool to service principal 
  - https://docs.microsoft.com/en-gb/azure/data-factory/connector-azure-sql-data-warehouse#using-managed-service-identity-authentication
  - make one click deployment
  
### Purview Starter Kit Notes:

- Creates Blob storage and populates account with data
- Creates ADLS gen2
- Creates ADF and associates the instance to Purview
- Sets up and triggers a copy activity pipeline between the Blob storage, ADLS gen2 accounts and Synapse SQL pool
- Pushes the associated lineage from ADF to Purview
- Assigns relevant permissions to register with Purview and trigger scans (*with exception of Synapse Analytics workspace - *see notes below*)

### Implementation Notes

- Need to run the entire deployment script in PowerShell (run as administrator)

- Cloud file access denied error does cause issues with package installs. Currently registered as a bug with PowerShell package. Alternative way around this is to run individual Install-Module command direct in PowerShell.

- If issues running scripts on your machine and you get the following error:

`+ CategoryInfo : SecurityError: (:) [], PSSecurityException`
`+ FullyQualifiedErrorId : UnauthorizedAccess`

- Run following script to grant permissions:

- `Set-ExecutionPolicy -ExecutionPolicy UnRestricted -Scope CurrentUser`

 - When running in Powershell 7+ and if you also have Powersher 5.1 with AzureRM modules installed, you will running into some issues using this script:


    - Solution: Use: Import-Module AzureAD -UseWindowsPowerShell

    - Error:
``` Connect-AzureAD: C:\PurviewDemoHack\PurviewDemo\PurviewStarter\RunStarterKit.ps1:28
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
```
- Unable to create user in SQL pool for Purview Synapse Analytics data source scanning. this part will have to be manual due to restrictions on permissions within MSFT tenant.
  - https://docs.microsoft.com/en-us/azure/purview/register-scan-synapse-workspace#register-and-scan-an-azure-synapse-workspace