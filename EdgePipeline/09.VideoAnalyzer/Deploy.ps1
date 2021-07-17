param (
  $regionName = "",         # List Azure region names via Azure CLI (az account list-locations --query [].name)
  $resourceGroupPrefix = "" # Alphanumeric characters, periods, underscores, hyphens and parentheses are valid
)

$modulePath = $PSScriptRoot
Import-Module "$modulePath/../../SharedServices/Functions.psm1"

# 09.VideoAnalyzer
$moduleName = "09.VideoAnalyzer"
New-TraceMessage $moduleName $false

$templateResourcesPath = "$modulePath/Template.json"
$templateParametersPath = "$modulePath/Template.Parameters.json"

$resourceGroupName = Set-ResourceGroup $regionName $resourceGroupPrefix ".Pipeline"

$resourceDeployment = (az deployment group create --name $moduleName --resource-group $resourceGroupName --template-file $templateResourcesPath --parameters $templateParametersPath) | ConvertFrom-Json
$videoAnalyzer = $resourceDeployment.properties.outputs.videoAnalyzer.value

New-TraceMessage $moduleName $true
