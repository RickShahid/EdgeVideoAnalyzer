#!/bin/bash

regionName=""          # List Azure region names via Azure CLI (az account list-locations --query [].name)
resourceGroupPrefix="" # Alphanumeric characters, periods, underscores, hyphens and parentheses are valid

modulePath=$(pwd)
source "$modulePath/../../SharedServices/Functions.sh"

# 07.IoTHub
moduleName="07.IoTHub"
New-TraceMessage $moduleName false

templateResourcesPath="$modulePath/Template.json"
templateParametersPath="$modulePath/Template.Parameters.json"

resourceGroupName=$(Set-ResourceGroup $regionName $resourceGroupPrefix ".Hub")

resourceDeployment=$(az deployment group create --name $moduleName --resource-group $resourceGroupName --template-file "$templateResourcesPath" --parameters "$templateParametersPath")
iotHub=$(Get-PropertyValue "$resourceDeployment" .properties.outputs.iotHub.value false)

New-TraceMessage $moduleName true
