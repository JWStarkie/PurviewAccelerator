# PurviewDemo

## Need to figure out:

- how to store credentials/managed identity to synapse
- how to pass parameter down to nested scripts
- how to do one click deployment

## Things to do:

- add synapse, __done__
- add purview managed identity to synapse as db_owner/ or KV, __done__
- pass parameter of name and location down to TemplatePurview.Json, __done__
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


## notes 
need  to run below command in windows powershell prior to running the script
Install-Module AzureAD
