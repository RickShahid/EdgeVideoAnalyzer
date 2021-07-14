param (
  $regionName = "",         # List Azure region names via Azure CLI (az account list-locations --query [].name)
  $resourceGroupPrefix = "" # Alphanumeric characters, periods, underscores, hyphens and parentheses are valid
)

$modulePath = $PSScriptRoot
Import-Module "$modulePath/../../Shared/Functions.psm1"

# 04.NetworkGateway
$moduleName = "04.NetworkGateway"
New-TraceMessage $moduleName $false

$templateResourcesPath = "$modulePath/Template.json"
$templateParametersPath = "$modulePath/Template.Parameters.json"

$resourceGroupName = Set-ResourceGroup $regionName $resourceGroupPrefix ".Network"

az deployment group create --name $moduleName --resource-group $resourceGroupName --template-file $templateResourcesPath --parameters $templateParametersPath

New-TraceMessage $moduleName $true