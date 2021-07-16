#!/bin/bash

regionName=""          # List Azure region names via Azure CLI (az account list-locations --query [].name)
resourceGroupPrefix="" # Alphanumeric characters, periods, underscores, hyphens and parentheses are valid

modulePath=$(pwd)
source "$modulePath/../../Shared/Functions.sh"

# 06.TimeSeriesInsights
moduleName="06.TimeSeriesInsights"
New-TraceMessage $moduleName false

templateResourcesPath="$modulePath/Template.json"
templateParametersPath="$modulePath/Template.Parameters.json"

currentUser=$(az ad signed-in-user show)
currentUserPrincipalId=$(Get-PropertyValue "$currentUser" .objectId false)
Set-TemplateParameter $templateParametersPath "insightEnvironment" "accessPolicies.principalId" $currentUserPrincipalId 0

resourceGroupName=$(Set-ResourceGroup $regionName $resourceGroupPrefix ".Data")

az deployment group create --name $moduleName --resource-group $resourceGroupName --template-file "$templateResourcesPath" --parameters "$templateParametersPath"

New-TraceMessage $moduleName true
