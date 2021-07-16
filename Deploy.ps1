param (
  $regionName = "",         # List Azure region names via Azure CLI (az account list-locations --query [].name)
  $resourceGroupPrefix = "" # Alphanumeric characters, periods, underscores, hyphens and parentheses are valid
)

$scriptRoot = $PSScriptRoot
Import-Module "$scriptRoot/Shared/Functions.psm1"

$modulePath = "$scriptRoot/BaseFramework"

# 01.VirtualNetwork
$moduleName = "01.VirtualNetwork"
New-TraceMessage $moduleName $false

$templateResourcesPath = "$modulePath/01.VirtualNetwork/Template.json"
$templateParametersPath = "$modulePath/01.VirtualNetwork/Template.Parameters.json"

$resourceGroupName = Set-ResourceGroup $regionName $resourceGroupPrefix ".Network"

$resourceDeployment = (az deployment group create --name $moduleName --resource-group $resourceGroupName --template-file $templateResourcesPath --parameters $templateParametersPath) | ConvertFrom-Json
$virtualNetwork = $resourceDeployment.properties.outputs.virtualNetwork.value

New-TraceMessage $moduleName $true

# 02.ManagedIdentity
$moduleName = "02.ManagedIdentity"
New-TraceMessage $moduleName $false

$templateResourcesPath = "$modulePath/02.ManagedIdentity/Template.json"
$templateParametersPath = "$modulePath/02.ManagedIdentity/Template.Parameters.json"

$resourceGroupName = Set-ResourceGroup $regionName $resourceGroupPrefix ""

$resourceDeployment = (az deployment group create --name $moduleName --resource-group $resourceGroupName --template-file $templateResourcesPath --parameters $templateParametersPath) | ConvertFrom-Json
$managedIdentity = $resourceDeployment.properties.outputs.managedIdentity.value

New-TraceMessage $moduleName $true

# 03.KeyVault
$moduleName = "03.KeyVault"
New-TraceMessage $moduleName $false

$templateResourcesPath = "$modulePath/03.KeyVault/Template.json"
$templateParametersPath = "$modulePath/03.KeyVault/Template.Parameters.json"

$currentUser = (az ad signed-in-user show) | ConvertFrom-Json
Set-TemplateParameter $templateParametersPath "keyVault" "roleAssignments.principalId" $currentUser.objectId 0
Set-TemplateParameter $templateParametersPath "keyVault" "roleAssignments.principalId" $managedIdentity.principalId 1
Set-TemplateParameter $templateParametersPath "keyVault" "roleAssignments.principalId" $managedIdentity.principalId 2

Set-TemplateParameter $templateParametersPath "virtualNetwork" "name" $virtualNetwork.name
Set-TemplateParameter $templateParametersPath "virtualNetwork" "resourceGroupName" $virtualNetwork.resourceGroupName

$resourceGroupName = Set-ResourceGroup $regionName $resourceGroupPrefix ""

$resourceDeployment = (az deployment group create --name $moduleName --resource-group $resourceGroupName --template-file $templateResourcesPath --parameters $templateParametersPath) | ConvertFrom-Json
$keyVault = $resourceDeployment.properties.outputs.keyVault.value

New-TraceMessage $moduleName $true

# 04.NetworkGateway
$moduleName = "04.NetworkGateway"
New-TraceMessage $moduleName $false

$templateResourcesPath = "$modulePath/04.NetworkGateway/Template.json"
$templateParametersPath = "$modulePath/04.NetworkGateway/Template.Parameters.json"

Set-TemplateParameter $templateParametersPath "networkGateway" "name" $virtualNetwork.name

$keyName = "networkConnectionKey"
$keyVaultRef = New-Object PSObject
$keyVaultRef | Add-Member -MemberType NoteProperty -Name "id" -Value $keyVault.resourceId
Set-TemplateParameter $templateParametersPath $keyName "keyVault" $keyVaultRef
Set-TemplateParameter $templateParametersPath $keyName "secretName" $keyName

$resourceGroupName = Set-ResourceGroup $regionName $resourceGroupPrefix ".Network"

$resourceDeployment = (az deployment group create --name $moduleName --resource-group $resourceGroupName --template-file $templateResourcesPath --parameters $templateParametersPath) | ConvertFrom-Json
$networkGateway = $resourceDeployment.properties.outputs.networkGateway.value

New-TraceMessage $moduleName $true

$modulePath = "$scriptRoot/IoTSolution"

# 05.StorageAccount
$moduleName = "05.StorageAccount"
New-TraceMessage $moduleName $false

$templateResourcesPath = "$modulePath/05.StorageAccount/Template.json"
$templateParametersPath = "$modulePath/05.StorageAccount/Template.Parameters.json"

Set-TemplateParameter $templateParametersPath "roleAssignments" "principalId" $managedIdentity.principalId 0 $true
Set-TemplateParameter $templateParametersPath "roleAssignments" "principalId" $managedIdentity.principalId 1 $true

Set-TemplateParameter $templateParametersPath "virtualNetwork" "name" $virtualNetwork.name
Set-TemplateParameter $templateParametersPath "virtualNetwork" "resourceGroupName" $virtualNetwork.resourceGroupName

$resourceGroupName = Set-ResourceGroup $regionName $resourceGroupPrefix ".Data"

$resourceDeployment = (az deployment group create --name $moduleName --resource-group $resourceGroupName --template-file $templateResourcesPath --parameters $templateParametersPath) | ConvertFrom-Json
$storageAccount = $resourceDeployment.properties.outputs.storageAccount.value

New-TraceMessage $moduleName $true

# 06.TimeSeriesInsights
$moduleName = "06.TimeSeriesInsights"
New-TraceMessage $moduleName $false

$templateResourcesPath = "$modulePath/06.TimeSeriesInsights/Template.json"
$templateParametersPath = "$modulePath/06.TimeSeriesInsights/Template.Parameters.json"

Set-TemplateParameter $templateParametersPath "storageAccount" "name" $storageAccount.name

$resourceGroupName = Set-ResourceGroup $regionName $resourceGroupPrefix ".Data"

$resourceDeployment = (az deployment group create --name $moduleName --resource-group $resourceGroupName --template-file $templateResourcesPath --parameters $templateParametersPath) | ConvertFrom-Json
$insightEnvironment = $resourceDeployment.properties.outputs.insightEnvironment.value

New-TraceMessage $moduleName $true

# 07.IoTHub
$moduleName = "07.IoTHub"
New-TraceMessage $moduleName $false

$templateResourcesPath = "$modulePath/07.IoTHub/Template.json"
$templateParametersPath = "$modulePath/07.IoTHub/Template.Parameters.json"

Set-TemplateParameter $templateParametersPath "managedIdentity" "name" $managedIdentity.name
Set-TemplateParameter $templateParametersPath "managedIdentity" "resourceGroupName" $managedIdentity.resourceGroupName

Set-TemplateParameter $templateParametersPath "insightEnvironment" "name" $insightEnvironment.name
Set-TemplateParameter $templateParametersPath "insightEnvironment" "resourceGroupName" $insightEnvironment.resourceGroupName

Set-TemplateParameter $templateParametersPath "virtualNetwork" "name" $virtualNetwork.name
Set-TemplateParameter $templateParametersPath "virtualNetwork" "resourceGroupName" $virtualNetwork.resourceGroupName

$resourceGroupName = Set-ResourceGroup $regionName $resourceGroupPrefix ".Device"

$resourceDeployment = (az deployment group create --name $moduleName --resource-group $resourceGroupName --template-file $templateResourcesPath --parameters $templateParametersPath) | ConvertFrom-Json
$iotHub = $resourceDeployment.properties.outputs.iotHub.value

New-TraceMessage $moduleName $true

# 08.VideoAnalyzer
$moduleName = "08.VideoAnalyzer"
New-TraceMessage $moduleName $false

$templateResourcesPath = "$modulePath/08.VideoAnalyzer/Template.json"
$templateParametersPath = "$modulePath/08.VideoAnalyzer/Template.Parameters.json"

Set-TemplateParameter $templateParametersPath "managedIdentity" "name" $managedIdentity.name
Set-TemplateParameter $templateParametersPath "managedIdentity" "resourceGroupName" $managedIdentity.resourceGroupName

Set-TemplateParameter $templateParametersPath "keyVault" "name" $keyVault.name
Set-TemplateParameter $templateParametersPath "keyVault" "resourceGroupName" $keyVault.resourceGroupName

Set-TemplateParameter $templateParametersPath "storageAccounts" "name" $storageAccount.name 0 $true
Set-TemplateParameter $templateParametersPath "storageAccounts" "resourceGroupName" $storageAccount.resourceGroupName 0 $true

$resourceGroupName = Set-ResourceGroup $regionName $resourceGroupPrefix ".Pipeline"

$resourceDeployment = (az deployment group create --name $moduleName --resource-group $resourceGroupName --template-file $templateResourcesPath --parameters $templateParametersPath) | ConvertFrom-Json
$videoAnalyzer = $resourceDeployment.properties.outputs.videoAnalyzer.value

New-TraceMessage $moduleName $true
