param (
  $regionName = "",       # List Azure region names via Azure CLI (az account list-locations --query [].name)
  $resourceGroupName = "" # Alphanumeric characters, periods, underscores, hyphens and parentheses are valid
)

$modulePath = $PSScriptRoot

$templateResourcesPath = "$modulePath/Template.json"
$templateParametersPath = "$modulePath/Template.Parameters.json"

az group create --name $resourceGroupName --location $regionName

az deployment group create --resource-group $resourceGroupName --template-file $templateResourcesPath --parameters $templateParametersPath
