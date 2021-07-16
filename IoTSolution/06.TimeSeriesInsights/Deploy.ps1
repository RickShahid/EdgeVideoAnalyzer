param (
  $regionName = "",         # List Azure region names via Azure CLI (az account list-locations --query [].name)
  $resourceGroupPrefix = "" # Alphanumeric characters, periods, underscores, hyphens and parentheses are valid
)

$modulePath = $PSScriptRoot
Import-Module "$modulePath/../../Shared/Functions.psm1"

# 06.TimeSeriesInsights
$moduleName = "06.TimeSeriesInsights"
New-TraceMessage $moduleName $false

$templateResourcesPath = "$modulePath/Template.json"
$templateParametersPath = "$modulePath/Template.Parameters.json"

$currentUser = (az ad signed-in-user show) | ConvertFrom-Json
Set-TemplateParameter $templateParametersPath "insightEnvironment" "accessPolicies.principalId" $currentUser.objectId 0

$resourceGroupName = Set-ResourceGroup $regionName $resourceGroupPrefix ".Data"

az deployment group create --name $moduleName --resource-group $resourceGroupName --template-file $templateResourcesPath --parameters $templateParametersPath

New-TraceMessage $moduleName $true
