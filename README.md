# PurviewDemo

## Need to figure out:

- how to store credentials/managed identity to synapse
- how to pass parameter down to nested scripts
- how to do one click deployment

## Things to do:

- add synapse
- add copy pipeline from gen2 to synapse (link synapse and adf using credentials/managed identity)
- add synapse to purview (link synapse and purview using credentials/managed identity)

## Purview Starter Kit Notes:

- Creates Blob storage and populates account with data
- Creates ADLS gen2
- Creates ADF and associates the instance to Purview
- Sets up and triggers a copy activity pipeline between the Blob storage and ADLS gen2 accounts
- Pushes the associated lineage from ADF to Purview
