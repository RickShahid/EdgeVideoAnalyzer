param (
  $regionName = "",         # List Azure region names via Azure CLI (az account list-locations --query [].name)
  $resourceGroupPrefix = "" # Alphanumeric characters, periods, underscores, hyphens and parentheses are valid
)

$scriptRoot = $PSScriptRoot
Import-Module "$scriptRoot/SharedServices/Functions.psm1"

$modulePath = "$scriptRoot/SharedServices"

# 00.MonitorTelemetry
$moduleName = "00.MonitorTelemetry"
New-TraceMessage $moduleName $false

$templateResourcesPath = "$modulePath/$moduleName/Template.json"
$templateParametersPath = "$modulePath/$moduleName/Template.Parameters.json"

$resourceGroupName = Set-ResourceGroup $regionName $resourceGroupPrefix ""

$resourceDeployment = (az deployment group create --name $moduleName --resource-group $resourceGroupName --template-file $templateResourcesPath --parameters $templateParametersPath) | ConvertFrom-Json
$logAnalytics = $resourceDeployment.properties.outputs.logAnalytics.value
$appInsights = $resourceDeployment.properties.outputs.appInsights.value

New-TraceMessage $moduleName $true

# 01.VirtualNetwork
$moduleName = "01.VirtualNetwork"
New-TraceMessage $moduleName $false

$templateResourcesPath = "$modulePath/$moduleName/Template.json"
$templateParametersPath = "$modulePath/$moduleName/Template.Parameters.json"

$resourceGroupName = Set-ResourceGroup $regionName $resourceGroupPrefix ".Network"

$resourceDeployment = (az deployment group create --name $moduleName --resource-group $resourceGroupName --template-file $templateResourcesPath --parameters $templateParametersPath) | ConvertFrom-Json
$virtualNetwork = $resourceDeployment.properties.outputs.virtualNetwork.value

New-TraceMessage $moduleName $true

# 02.ManagedIdentity
$moduleName = "02.ManagedIdentity"
New-TraceMessage $moduleName $false

$templateResourcesPath = "$modulePath/$moduleName/Template.json"
$templateParametersPath = "$modulePath/$moduleName/Template.Parameters.json"

$resourceGroupName = Set-ResourceGroup $regionName $resourceGroupPrefix ""

$resourceDeployment = (az deployment group create --name $moduleName --resource-group $resourceGroupName --template-file $templateResourcesPath --parameters $templateParametersPath) | ConvertFrom-Json
$managedIdentity = $resourceDeployment.properties.outputs.managedIdentity.value

New-TraceMessage $moduleName $true

# 03.KeyVault
$moduleName = "03.KeyVault"
New-TraceMessage $moduleName $false

$templateResourcesPath = "$modulePath/$moduleName/Template.json"
$templateParametersPath = "$modulePath/$moduleName/Template.Parameters.json"

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

$templateResourcesPath = "$modulePath/$moduleName/Template.json"
$templateParametersPath = "$modulePath/$moduleName/Template.Parameters.json"

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

$modulePath = "$scriptRoot/IoTFramework"

# 05.StorageAccount
$moduleName = "05.StorageAccount"
New-TraceMessage $moduleName $false

$templateResourcesPath = "$modulePath/$moduleName/Template.json"
$templateParametersPath = "$modulePath/$moduleName/Template.Parameters.json"

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

$templateResourcesPath = "$modulePath/$moduleName/Template.json"
$templateParametersPath = "$modulePath/$moduleName/Template.Parameters.json"

Set-TemplateParameter $templateParametersPath "storageAccount" "name" $storageAccount.name

$resourceGroupName = Set-ResourceGroup $regionName $resourceGroupPrefix ".Data"

$resourceDeployment = (az deployment group create --name $moduleName --resource-group $resourceGroupName --template-file $templateResourcesPath --parameters $templateParametersPath) | ConvertFrom-Json
$insightEnvironment = $resourceDeployment.properties.outputs.insightEnvironment.value

New-TraceMessage $moduleName $true

# 07.IoTHub
$moduleName = "07.IoTHub"
New-TraceMessage $moduleName $false

$templateResourcesPath = "$modulePath/$moduleName/Template.json"
$templateParametersPath = "$modulePath/$moduleName/Template.Parameters.json"

Set-TemplateParameter $templateParametersPath "logAnalytics" "name" $logAnalytics.name
Set-TemplateParameter $templateParametersPath "logAnalytics" "resourceGroupName" $logAnalytics.resourceGroupName

Set-TemplateParameter $templateParametersPath "managedIdentity" "name" $managedIdentity.name
Set-TemplateParameter $templateParametersPath "managedIdentity" "resourceGroupName" $managedIdentity.resourceGroupName

Set-TemplateParameter $templateParametersPath "insightEnvironment" "name" $insightEnvironment.name
Set-TemplateParameter $templateParametersPath "insightEnvironment" "resourceGroupName" $insightEnvironment.resourceGroupName

Set-TemplateParameter $templateParametersPath "virtualNetwork" "name" $virtualNetwork.name
Set-TemplateParameter $templateParametersPath "virtualNetwork" "resourceGroupName" $virtualNetwork.resourceGroupName

$resourceGroupName = Set-ResourceGroup $regionName $resourceGroupPrefix ".Hub"

$resourceDeployment = (az deployment group create --name $moduleName --resource-group $resourceGroupName --template-file $templateResourcesPath --parameters $templateParametersPath) | ConvertFrom-Json
$iotHub = $resourceDeployment.properties.outputs.iotHub.value

New-TraceMessage $moduleName $true

# 08.IoTDevice
$moduleName = "08.IoTDevice"
New-TraceMessage $moduleName $false

$templateResourcesPath = "$modulePath/$moduleName/Template.json"
$templateParametersPath = "$modulePath/$moduleName/Template.Parameters.json"

Set-TemplateParameter $templateParametersPath "iotHub" "name" $iotHub.name
Set-TemplateParameter $templateParametersPath "iotHub" "resourceGroupName" $iotHub.resourceGroupName

Set-TemplateParameter $templateParametersPath "virtualNetwork" "name" $virtualNetwork.name
Set-TemplateParameter $templateParametersPath "virtualNetwork" "resourceGroupName" $virtualNetwork.resourceGroupName

$resourceGroupName = Set-ResourceGroup $regionName $resourceGroupPrefix ".Device"

$resourceDeployment = (az deployment group create --name $moduleName --resource-group $resourceGroupName --template-file $templateResourcesPath --parameters $templateParametersPath) | ConvertFrom-Json
$iotDeviceProvisioning = $resourceDeployment.properties.outputs.iotDeviceProvisioning.value

$iotDeviceEnrollmentGroupId = "cameras"
$iotDeviceEnrollmentGroupExists = ((az iot dps enrollment-group list --resource-group $resourceGroupName --dps-name $iotDeviceProvisioning.name --query "[?enrollmentGroupId=='$iotDeviceEnrollmentGroupId']") | ConvertFrom-Json).Count -gt 0
if (!$iotDeviceEnrollmentGroupExists) {
  $iotDeviceEnrollmentGroup = (az iot dps enrollment-group create --resource-group $resourceGroupName --dps-name $iotDeviceProvisioning.name --enrollment-id $iotDeviceEnrollmentGroupId --edge-enabled) | ConvertFrom-Json
}

New-TraceMessage $moduleName $true

$modulePath = "$scriptRoot/EdgePipeline"

# 09.VideoAnalyzer
$moduleName = "09.VideoAnalyzer"
New-TraceMessage $moduleName $false

$templateResourcesPath = "$modulePath/$moduleName/Template.json"
$templateParametersPath = "$modulePath/$moduleName/Template.Parameters.json"

Set-TemplateParameter $templateParametersPath "managedIdentity" "name" $managedIdentity.name
Set-TemplateParameter $templateParametersPath "managedIdentity" "resourceGroupName" $managedIdentity.resourceGroupName

Set-TemplateParameter $templateParametersPath "keyVault" "name" $keyVault.name
Set-TemplateParameter $templateParametersPath "keyVault" "resourceGroupName" $keyVault.resourceGroupName

Set-TemplateParameter $templateParametersPath "storageAccounts" "name" $storageAccount.name 0 $true
Set-TemplateParameter $templateParametersPath "storageAccounts" "resourceGroupName" $storageAccount.resourceGroupName 0 $true

$resourceGroupName = Set-ResourceGroup $regionName $resourceGroupPrefix ".Pipeline"

$resourceDeployment = (az deployment group create --name $moduleName --resource-group $resourceGroupName --template-file $templateResourcesPath --parameters $templateParametersPath) | ConvertFrom-Json
$videoAnalyzer = $resourceDeployment.properties.outputs.videoAnalyzer.value

$iotEdgeConfigPath = "$modulePath/$moduleName/IoTEdge.json"
Set-ProvisioningToken $iotEdgeConfigPath $videoAnalyzer.provisioningToken

New-TraceMessage $moduleName $true

# 10.MediaServices
$moduleName = "10.MediaServices"
New-TraceMessage $moduleName $false

$templateResourcesPath = "$modulePath/$moduleName/Template.json"
$templateParametersPath = "$modulePath/$moduleName/Template.Parameters.json"

Set-TemplateParameter $templateParametersPath "storageAccounts" "name" $storageAccount.name 0 $true
Set-TemplateParameter $templateParametersPath "storageAccounts" "resourceGroupName" $storageAccount.resourceGroupName 0 $true

$resourceGroupName = Set-ResourceGroup $regionName $resourceGroupPrefix ".Pipeline"

$resourceDeployment = (az deployment group create --name $moduleName --resource-group $resourceGroupName --template-file $templateResourcesPath --parameters $templateParametersPath) | ConvertFrom-Json
$mediaAccount = $resourceDeployment.properties.outputs.mediaAccount.value

New-TraceMessage $moduleName $true
