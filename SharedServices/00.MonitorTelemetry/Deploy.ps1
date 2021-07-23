param (
  $regionName = "",         # List Azure region names via Azure CLI (az account list-locations --query [].name)
  $resourceGroupPrefix = "" # Alphanumeric characters, periods, underscores, hyphens and parentheses are valid
)

$modulePath = $PSScriptRoot
Import-Module "$modulePath/../SharedServices/Functions.psm1"

# 00.MonitorTelemetry
$moduleName = "00.MonitorTelemetry"
New-TraceMessage $moduleName $false

$templateResourcesPath = "$modulePath/Template.json"
$templateParametersPath = "$modulePath/Template.Parameters.json"

$resourceGroupName = Set-ResourceGroup $regionName $resourceGroupPrefix ""

$resourceDeployment = (az deployment group create --name $moduleName --resource-group $resourceGroupName --template-file $templateResourcesPath --parameters $templateParametersPath) | ConvertFrom-Json
$virtualNetwork = $resourceDeployment.properties.outputs.virtualNetwork.value

New-TraceMessage $moduleName $true
