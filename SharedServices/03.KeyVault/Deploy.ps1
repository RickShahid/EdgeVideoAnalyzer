param (
  $regionName = "",         # List Azure region names via Azure CLI (az account list-locations --query [].name)
  $resourceGroupPrefix = "" # Alphanumeric characters, periods, underscores, hyphens and parentheses are valid
)

$modulePath = $PSScriptRoot
Import-Module "$modulePath/../SharedServices/Functions.psm1"

# 03.KeyVault
$moduleName = "03.KeyVault"
New-TraceMessage $moduleName $false

$templateResourcesPath = "$modulePath/Template.json"
$templateParametersPath = "$modulePath/Template.Parameters.json"

$currentUser = (az ad signed-in-user show) | ConvertFrom-Json
Set-TemplateParameter $templateParametersPath "keyVault" "roleAssignments.principalId" $currentUser.objectId 0

$resourceGroupName = Set-ResourceGroup $regionName $resourceGroupPrefix ""

$resourceDeployment = (az deployment group create --name $moduleName --resource-group $resourceGroupName --template-file $templateResourcesPath --parameters $templateParametersPath) | ConvertFrom-Json
$keyVault = $resourceDeployment.properties.outputs.keyVault.value

New-TraceMessage $moduleName $true
