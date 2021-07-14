#!/bin/bash

regionName=""          # List Azure region names via Azure CLI (az account list-locations --query [].name)
resourceGroupPrefix="" # Alphanumeric characters, periods, underscores, hyphens and parentheses are valid

scriptRoot=$(pwd)
source "$scriptRoot/Shared/Functions.sh"

modulePath="$scriptRoot/BaseFramework"

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
virtualNetworkResourceGroupName=$(Get-PropertyValue "$virtualNetwork" .resourceGroupName false)
Set-TemplateParameter $templateParametersPath "virtualNetwork" "name" $virtualNetworkName
Set-TemplateParameter $templateParametersPath "virtualNetwork" "resourceGroupName" $virtualNetworkResourceGroupName

keyName="networkConnectionKey"
keyVaultId=$(Get-PropertyValue "$keyVault" .resourceId false)
Set-TemplateParameter $templateParametersPath $keyName "keyVault.id" $keyVaultId
Set-TemplateParameter $templateParametersPath $keyName "secretName" $keyName

resourceGroupName=$(Set-ResourceGroup $regionName $resourceGroupPrefix ".Network")

resourceDeployment=$(az deployment group create --name $moduleName --resource-group $resourceGroupName --template-file "$templateResourcesPath" --parameters "$templateParametersPath")
networkGateway=$(Get-PropertyValue "$resourceDeployment" .properties.outputs.networkGateway.value false)

New-TraceMessage $moduleName true

modulePath="$scriptRoot/IoTSolution"

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

resourceGroupName=$(Set-ResourceGroup $regionName $resourceGroupPrefix ".Insight")

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

resourceGroupName=$(Set-ResourceGroup $regionName $resourceGroupPrefix ".Insight")

resourceDeployment=$(az deployment group create --name $moduleName --resource-group $resourceGroupName --template-file "$templateResourcesPath" --parameters "$templateParametersPath")
insightEnvironment=$(Get-PropertyValue "$resourceDeployment" .properties.outputs.insightEnvironment.value false)

New-TraceMessage $moduleName true

# 07.IoTHub
moduleName="07.IoTHub"
New-TraceMessage $moduleName false

templateResourcesPath="$modulePath/07.IoTHub/Template.json"
templateParametersPath="$modulePath/07.IoTHub/Template.Parameters.json"

manageIdentityName=$(Get-PropertyValue "$manageIdentity" .name false)
manageIdentityResourceGroupName=$(Get-PropertyValue "$manageIdentity" .resourceGroupName false)
Set-TemplateParameter $templateParametersPath "manageIdentity" "name" $manageIdentityName
Set-TemplateParameter $templateParametersPath "manageIdentity" "resourceGroupName" $manageIdentityResourceGroupName

virtualNetworkName=$(Get-PropertyValue "$virtualNetwork" .name false)
virtualNetworkResourceGroupName=$(Get-PropertyValue "$virtualNetwork" .resourceGroupName false)
Set-TemplateParameter $templateParametersPath "virtualNetwork" "name" $virtualNetworkName
Set-TemplateParameter $templateParametersPath "virtualNetwork" "resourceGroupName" $virtualNetworkResourceGroupName

resourceGroupName=$(Set-ResourceGroup $regionName $resourceGroupPrefix ".IoT")

resourceDeployment=$(az deployment group create --name $moduleName --resource-group $resourceGroupName --template-file "$templateResourcesPath" --parameters "$templateParametersPath")
iotHub=$(Get-PropertyValue "$resourceDeployment" .properties.outputs.iotHub.value false)

New-TraceMessage $moduleName true
