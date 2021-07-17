#!/bin/bash

regionName=""          # List Azure region names via Azure CLI (az account list-locations --query [].name)
resourceGroupPrefix="" # Alphanumeric characters, periods, underscores, hyphens and parentheses are valid

modulePath=$(pwd)
source "$modulePath/../SharedServices/Functions.sh"

# 01.VirtualNetwork
moduleName="01.VirtualNetwork"
New-TraceMessage $moduleName false

templateResourcesPath="$modulePath/Template.json"
templateParametersPath="$modulePath/Template.Parameters.json"

resourceGroupName=$(Set-ResourceGroup $regionName $resourceGroupPrefix ".Network")

resourceDeployment=$(az deployment group create --name $moduleName --resource-group $resourceGroupName --template-file "$templateResourcesPath" --parameters "$templateParametersPath")
virtualNetwork=$(Get-PropertyValue "$resourceDeployment" .properties.outputs.virtualNetwork.value false)

New-TraceMessage $moduleName true
