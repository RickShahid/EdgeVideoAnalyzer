#!/bin/bash

regionName=""          # List Azure region names via Azure CLI (az account list-locations --query [].name)
resourceGroupPrefix="" # Alphanumeric characters, periods, underscores, hyphens and parentheses are valid

modulePath=$(pwd)
source "$modulePath/../SharedServices/Functions.sh"

# 03.KeyVault
moduleName="03.KeyVault"
New-TraceMessage $moduleName false

templateResourcesPath="$modulePath/Template.json"
templateParametersPath="$modulePath/Template.Parameters.json"

currentUser=$(az ad signed-in-user show)
currentUserPrincipalId=$(Get-PropertyValue "$currentUser" .objectId false)
Set-TemplateParameter $templateParametersPath "keyVault" "roleAssignments.principalId" $currentUserPrincipalId 0

resourceGroupName=$(Set-ResourceGroup $regionName $resourceGroupPrefix "")

az deployment group create --name $moduleName --resource-group $resourceGroupName --template-file "$templateResourcesPath" --parameters "$templateParametersPath"

New-TraceMessage $moduleName true
