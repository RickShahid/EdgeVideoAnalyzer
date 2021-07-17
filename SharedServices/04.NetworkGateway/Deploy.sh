#!/bin/bash

regionName=""          # List Azure region names via Azure CLI (az account list-locations --query [].name)
resourceGroupPrefix="" # Alphanumeric characters, periods, underscores, hyphens and parentheses are valid

modulePath=$(pwd)
source "$modulePath/../SharedServices/Functions.sh"

# 04.NetworkGateway
moduleName="04.NetworkGateway"
New-TraceMessage $moduleName false

templateResourcesPath="$modulePath/Template.json"
templateParametersPath="$modulePath/Template.Parameters.json"

resourceGroupName=$(Set-ResourceGroup $regionName $resourceGroupPrefix ".Network")

resourceDeployment=$(az deployment group create --name $moduleName --resource-group $resourceGroupName --template-file "$templateResourcesPath" --parameters "$templateParametersPath")
networkGateway=$(Get-PropertyValue "$resourceDeployment" .properties.outputs.networkGateway.value false)

New-TraceMessage $moduleName true
