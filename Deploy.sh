#!/bin/bash

regionName=""          # List Azure region names via Azure CLI (az account list-locations --query [].name)
resourceGroupPrefix="" # Alphanumeric characters, periods, underscores, hyphens and parentheses are valid

scriptRoot=$(pwd)
source "$scriptRoot/SharedServices/Functions.sh"

modulePath="$scriptRoot/SharedServices"

# 00.MonitorTelemetry
moduleName="00.MonitorTelemetry"
New-TraceMessage $moduleName false

templateResourcesPath="$modulePath/00.MonitorTelemetry/Template.json"
templateParametersPath="$modulePath/00.MonitorTelemetry/Template.Parameters.json"

resourceGroupName=$(Set-ResourceGroup $regionName $resourceGroupPrefix "")

resourceDeployment=$(az deployment group create --name $moduleName --resource-group $resourceGroupName --template-file "$templateResourcesPath" --parameters "$templateParametersPath")
logAnalytics=$(Get-PropertyValue "$resourceDeployment" .properties.outputs.logAnalytics.value false)
appInsights=$(Get-PropertyValue "$resourceDeployment" .properties.outputs.appInsights.value false)

New-TraceMessage $moduleName true

# 01.VirtualNetwork
moduleName="01.VirtualNetwork"
New-TraceMessage $moduleName false

templateResourcesPath="$modulePath/01.VirtualNetwork/Template.json"
templateParametersPath="$modulePath/01.VirtualNetwork/Template.Parameters.json"

resourceGroupName=$(Set-ResourceGroup $regionName $resourceGroupPrefix ".Network")

resourceDeployment=$(az deployment group create --name $moduleName --resource-group $resourceGroupName --template-file "$templateResourcesPath" --parameters "$templateParametersPath")
virtualNetwork=$(Get-PropertyValue "$resourceDeployment" .properties.outputs.virtualNetwork.value false)

New-TraceMessage $moduleName true

# 02.ManagedIdentity
moduleName="02.ManagedIdentity"
New-TraceMessage $moduleName false

templateResourcesPath="$modulePath/02.ManagedIdentity/Template.json"
templateParametersPath="$modulePath/02.ManagedIdentity/Template.Parameters.json"

resourceGroupName=$(Set-ResourceGroup $regionName $resourceGroupPrefix "")

resourceDeployment=$(az deployment group create --name $moduleName --resource-group $resourceGroupName --template-file "$templateResourcesPath" --parameters "$templateParametersPath")
managedIdentity=$(Get-PropertyValue "$resourceDeployment" .properties.outputs.managedIdentity.value false)

New-TraceMessage $moduleName true

# 03.KeyVault
moduleName="03.KeyVault"
New-TraceMessage $moduleName false

templateResourcesPath="$modulePath/03.KeyVault/Template.json"
templateParametersPath="$modulePath/03.KeyVault/Template.Parameters.json"

currentUser=$(az ad signed-in-user show)
currentUserPrincipalId=$(Get-PropertyValue "$currentUser" .objectId false)
managedIdentityPrincipalId=$(Get-PropertyValue "$managedIdentity" .principalId false)
Set-TemplateParameter $templateParametersPath "keyVault" "roleAssignments.principalId" $currentUserPrincipalId 0
Set-TemplateParameter $templateParametersPath "keyVault" "roleAssignments.principalId" $managedIdentityPrincipalId 1
Set-TemplateParameter $templateParametersPath "keyVault" "roleAssignments.principalId" $managedIdentityPrincipalId 2

virtualNetworkName=$(Get-PropertyValue "$virtualNetwork" .name false)
virtualNetworkResourceGroupName=$(Get-PropertyValue "$virtualNetwork" .resourceGroupName false)
Set-TemplateParameter $templateParametersPath "virtualNetwork" "name" $virtualNetworkName
Set-TemplateParameter $templateParametersPath "virtualNetwork" "resourceGroupName" $virtualNetworkResourceGroupName

resourceGroupName=$(Set-ResourceGroup $regionName $resourceGroupPrefix "")

resourceDeployment=$(az deployment group create --name $moduleName --resource-group $resourceGroupName --template-file "$templateResourcesPath" --parameters "$templateParametersPath")
keyVault=$(Get-PropertyValue "$resourceDeployment" .properties.outputs.keyVault.value false)

New-TraceMessage $moduleName true

# 04.NetworkGateway
moduleName="04.NetworkGateway"
New-TraceMessage $moduleName false

templateResourcesPath="$modulePath/04.NetworkGateway/Template.json"
templateParametersPath="$modulePath/04.NetworkGateway/Template.Parameters.json"

virtualNetworkName=$(Get-PropertyValue "$virtualNetwork" .name false)
Set-TemplateParameter $templateParametersPath "networkGateway" "name" $virtualNetworkName

keyName="networkConnectionKey"
keyVaultId=$(Get-PropertyValue "$keyVault" .resourceId false)
Set-TemplateParameter $templateParametersPath $keyName "keyVault.id" $keyVaultId
Set-TemplateParameter $templateParametersPath $keyName "secretName" $keyName

resourceGroupName=$(Set-ResourceGroup $regionName $resourceGroupPrefix ".Network")

resourceDeployment=$(az deployment group create --name $moduleName --resource-group $resourceGroupName --template-file "$templateResourcesPath" --parameters "$templateParametersPath")
networkGateway=$(Get-PropertyValue "$resourceDeployment" .properties.outputs.networkGateway.value false)

New-TraceMessage $moduleName true

modulePath="$scriptRoot/IoTFramework"

# 05.StoraegAccount
moduleName="05.StorageAccount"
New-TraceMessage $moduleName false

templateResourcesPath="$modulePath/05.StorageAccount/Template.json"
templateParametersPath="$modulePath/05.StorageAccount/Template.Parameters.json"

managedIdentityPrincipalId=$(Get-PropertyValue "$managedIdentity" .principalId false)
Set-TemplateParameter $templateParametersPath "roleAssignments" "principalId" $managedIdentityPrincipalId 0 true
Set-TemplateParameter $templateParametersPath "roleAssignments" "principalId" $managedIdentityPrincipalId 1 true

virtualNetworkName=$(Get-PropertyValue "$virtualNetwork" .name false)
virtualNetworkResourceGroupName=$(Get-PropertyValue "$virtualNetwork" .resourceGroupName false)
Set-TemplateParameter $templateParametersPath "virtualNetwork" "name" $virtualNetworkName
Set-TemplateParameter $templateParametersPath "virtualNetwork" "resourceGroupName" $virtualNetworkResourceGroupName

resourceGroupName=$(Set-ResourceGroup $regionName $resourceGroupPrefix ".Data")

resourceDeployment=$(az deployment group create --name $moduleName --resource-group $resourceGroupName --template-file "$templateResourcesPath" --parameters "$templateParametersPath")
storageAccount=$(Get-PropertyValue "$resourceDeployment" .properties.outputs.storageAccount.value false)

New-TraceMessage $moduleName true

# 06.TimeSeriesInsights
moduleName="06.TimeSeriesInsights"
New-TraceMessage $moduleName false

templateResourcesPath="$modulePath/06.TimeSeriesInsights/Template.json"
templateParametersPath="$modulePath/06.TimeSeriesInsights/Template.Parameters.json"

storageAccountName=$(Get-PropertyValue "$storageAccount" .name false)
Set-TemplateParameter $templateParametersPath "storageAccount" "name" $storageAccountName

resourceGroupName=$(Set-ResourceGroup $regionName $resourceGroupPrefix ".Data")

resourceDeployment=$(az deployment group create --name $moduleName --resource-group $resourceGroupName --template-file "$templateResourcesPath" --parameters "$templateParametersPath")
insightEnvironment=$(Get-PropertyValue "$resourceDeployment" .properties.outputs.insightEnvironment.value false)

New-TraceMessage $moduleName true

# 07.IoTHub
moduleName="07.IoTHub"
New-TraceMessage $moduleName false

templateResourcesPath="$modulePath/07.IoTHub/Template.json"
templateParametersPath="$modulePath/07.IoTHub/Template.Parameters.json"

logAnalyticsName=$(Get-PropertyValue "$logAnalytics" .name false)
logAnalyticsResourceGroupName=$(Get-PropertyValue "$logAnalytics" .resourceGroupName false)
Set-TemplateParameter $templateParametersPath "logAnalytics" "name" $logAnalyticsName
Set-TemplateParameter $templateParametersPath "logAnalytics" "resourceGroupName" $logAnalyticsResourceGroupName

managedIdentityName=$(Get-PropertyValue "$managedIdentity" .name false)
managedIdentityResourceGroupName=$(Get-PropertyValue "$managedIdentity" .resourceGroupName false)
Set-TemplateParameter $templateParametersPath "managedIdentity" "name" $managedIdentityName
Set-TemplateParameter $templateParametersPath "managedIdentity" "resourceGroupName" $managedIdentityResourceGroupName

insightEnvironmentName=$(Get-PropertyValue "$insightEnvironment" .name false)
insightEnvironmentResourceGroupName=$(Get-PropertyValue "$insightEnvironment" .resourceGroupName false)
Set-TemplateParameter $templateParametersPath "insightEnvironment" "name" $insightEnvironmentName
Set-TemplateParameter $templateParametersPath "insightEnvironment" "resourceGroupName" $insightEnvironmentResourceGroupName

virtualNetworkName=$(Get-PropertyValue "$virtualNetwork" .name false)
virtualNetworkResourceGroupName=$(Get-PropertyValue "$virtualNetwork" .resourceGroupName false)
Set-TemplateParameter $templateParametersPath "virtualNetwork" "name" $virtualNetworkName
Set-TemplateParameter $templateParametersPath "virtualNetwork" "resourceGroupName" $virtualNetworkResourceGroupName

resourceGroupName=$(Set-ResourceGroup $regionName $resourceGroupPrefix ".Hub")

resourceDeployment=$(az deployment group create --name $moduleName --resource-group $resourceGroupName --template-file "$templateResourcesPath" --parameters "$templateParametersPath")
iotHub=$(Get-PropertyValue "$resourceDeployment" .properties.outputs.iotHub.value false)

New-TraceMessage $moduleName true

# 08.IoTDevice
moduleName="08.IoTDevice"
New-TraceMessage $moduleName false

templateResourcesPath="$modulePath/08.IoTDevice/Template.json"
templateParametersPath="$modulePath/08.IoTDevice/Template.Parameters.json"

iotHubName=$(Get-PropertyValue "$iotHub" .name false)
iotHubResourceGroupName=$(Get-PropertyValue "$iotHub" .resourceGroupName false)
Set-TemplateParameter $templateParametersPath "iotHub" "name" $iotHubName
Set-TemplateParameter $templateParametersPath "iotHub" "resourceGroupName" $iotHubResourceGroupName

virtualNetworkName=$(Get-PropertyValue "$virtualNetwork" .name false)
virtualNetworkResourceGroupName=$(Get-PropertyValue "$virtualNetwork" .resourceGroupName false)
Set-TemplateParameter $templateParametersPath "virtualNetwork" "name" $virtualNetworkName
Set-TemplateParameter $templateParametersPath "virtualNetwork" "resourceGroupName" $virtualNetworkResourceGroupName

resourceGroupName=$(Set-ResourceGroup $regionName $resourceGroupPrefix ".Device")

resourceDeployment=$(az deployment group create --name $moduleName --resource-group $resourceGroupName --template-file "$templateResourcesPath" --parameters "$templateParametersPath")
iotDeviceProvisioning=$(Get-PropertyValue "$resourceDeployment" .properties.outputs.iotDeviceProvisioning.value false)

iotDeviceProvisioningName=$(Get-PropertyValue "$iotDeviceProvisioning" .name false)

iotDeviceEnrollmentGroupId="cameras"
iotDeviceEnrollmentGroupExists=$(az iot dps enrollment-group list --resource-group $resourceGroupName --dps-name $iotDeviceProvisioningName --query "[?enrollmentGroupId=='$iotDeviceEnrollmentGroupId']" | jq '. | length')
if [ "$iotDeviceEnrollmentGroupExists" != "1" ]; then
  iotDeviceEnrollmentGroup=$(az iot dps enrollment-group create --resource-group $resourceGroupName --dps-name $iotDeviceProvisioningName --enrollment-id "$iotDeviceEnrollmentGroupId" --edge-enabled)
fi

New-TraceMessage $moduleName true

modulePath="$scriptRoot/EdgePipeline"

# 09.VideoAnalyzer
moduleName="09.VideoAnalyzer"
New-TraceMessage $moduleName false

templateResourcesPath="$modulePath/09.VideoAnalyzer/Template.json"
templateParametersPath="$modulePath/09.VideoAnalyzer/Template.Parameters.json"

managedIdentityName=$(Get-PropertyValue "$managedIdentity" .name false)
managedIdentityResourceGroupName=$(Get-PropertyValue "$managedIdentity" .resourceGroupName false)
Set-TemplateParameter $templateParametersPath "managedIdentity" "name" $managedIdentityName
Set-TemplateParameter $templateParametersPath "managedIdentity" "resourceGroupName" $managedIdentityResourceGroupName

keyVaultName=$(Get-PropertyValue "$keyVault" .name false)
keyVaultResourceGroupName=$(Get-PropertyValue "$keyVault" .resourceGroupName false)
Set-TemplateParameter $templateParametersPath "keyVault" "name" $keyVaultName
Set-TemplateParameter $templateParametersPath "keyVault" "resourceGroupName" $keyVaultResourceGroupName

storageAccountName=$(Get-PropertyValue "$storageAccount" .name false)
storageAccountResourceGroupName=$(Get-PropertyValue "$storageAccount" .resourceGroupName false)
Set-TemplateParameter $templateParametersPath "storageAccounts" "name" $storageAccountName 0 true
Set-TemplateParameter $templateParametersPath "storageAccounts" "resourceGroupName" $storageAccountResourceGroupName 0 true

resourceGroupName=$(Set-ResourceGroup $regionName $resourceGroupPrefix ".Pipeline")

resourceDeployment=$(az deployment group create --name $moduleName --resource-group $resourceGroupName --template-file "$templateResourcesPath" --parameters "$templateParametersPath")
videoAnalyzer=$(Get-PropertyValue "$resourceDeployment" .properties.outputs.videoAnalyzer.value false)

New-TraceMessage $moduleName true

# 10.MediaServices
moduleName="10.MediaServices"
New-TraceMessage $moduleName false

templateResourcesPath="$modulePath/10.MediaServices/Template.json"
templateParametersPath="$modulePath/10.MediaServices/Template.Parameters.json"

storageAccountName=$(Get-PropertyValue "$storageAccount" .name false)
storageAccountResourceGroupName=$(Get-PropertyValue "$storageAccount" .resourceGroupName false)
Set-TemplateParameter $templateParametersPath "storageAccounts" "name" $storageAccountName 0 true
Set-TemplateParameter $templateParametersPath "storageAccounts" "resourceGroupName" $storageAccountResourceGroupName 0 true

resourceGroupName=$(Set-ResourceGroup $regionName $resourceGroupPrefix ".Pipeline")

resourceDeployment=$(az deployment group create --name $moduleName --resource-group $resourceGroupName --template-file "$templateResourcesPath" --parameters "$templateParametersPath")
mediaAccount=$(Get-PropertyValue "$resourceDeployment" .properties.outputs.mediaAccount.value false)

New-TraceMessage $moduleName true
