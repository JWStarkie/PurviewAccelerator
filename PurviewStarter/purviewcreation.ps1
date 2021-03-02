param (
    [string]$PurviewResourceGroup
)

New-AzResourceGroupDeployment -ResourceGroupName $PurviewResourceGroup -TemplateFile ".\purviewtemplate.json"