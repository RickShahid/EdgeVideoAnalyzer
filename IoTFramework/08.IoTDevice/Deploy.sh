#!/bin/bash

regionName=""          # List Azure region names via Azure CLI (az account list-locations --query [].name)
resourceGroupPrefix="" # Alphanumeric characters, periods, underscores, hyphens and parentheses are valid

modulePath=$(pwd)
source "$modulePath/../../SharedServices/Functions.sh"

# 08.IoTDevice
moduleName="08.IoTDevice"
New-TraceMessage $moduleName false

templateResourcesPath="$modulePath/Template.json"
templateParametersPath="$modulePath/Template.Parameters.json"

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
