param (
  $regionName = "",         # List Azure region names via Azure CLI (az account list-locations --query [].name)
  $resourceGroupPrefix = "" # Alphanumeric characters, periods, underscores, hyphens and parentheses are valid
)

$modulePath = $PSScriptRoot
Import-Module "$modulePath/../../SharedServices/Functions.psm1"

# 08.IoTDevice
$moduleName = "08.IoTDevice"
New-TraceMessage $moduleName $false

$templateResourcesPath = "$modulePath/Template.json"
$templateParametersPath = "$modulePath/Template.Parameters.json"

$resourceGroupName = Set-ResourceGroup $regionName $resourceGroupPrefix ".Device"

$resourceDeployment = (az deployment group create --name $moduleName --resource-group $resourceGroupName --template-file $templateResourcesPath --parameters $templateParametersPath) | ConvertFrom-Json
$iotDeviceProvisioning = $resourceDeployment.properties.outputs.iotDeviceProvisioning.value

$iotDeviceEnrollmentGroupId = "cameras"
$iotDeviceEnrollmentGroupExists = ((az iot dps enrollment-group list --resource-group $resourceGroupName --dps-name $iotDeviceProvisioning.name --query "[?enrollmentGroupId=='$iotDeviceEnrollmentGroupId']") | ConvertFrom-Json).Count -gt 0
if (!$iotDeviceEnrollmentGroupExists) {
  $iotDeviceEnrollmentGroup = (az iot dps enrollment-group create --resource-group $resourceGroupName --dps-name $iotDeviceProvisioning.name --enrollment-id $iotDeviceEnrollmentGroupId --edge-enabled) | ConvertFrom-Json
}

New-TraceMessage $moduleName $true
