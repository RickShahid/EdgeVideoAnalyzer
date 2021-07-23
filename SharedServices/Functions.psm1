function New-TraceMessage ($moduleName, $moduleEnd) {
  $traceMessage = Get-Date -Format "hh:mm:ss"
  if ($moduleEnd) {
    $traceMessage += "   END"
  } else {
    $traceMessage += " START"
  }
  Write-Host "$traceMessage $moduleName"
}

function Set-ResourceGroup ($regionName, $resourceGroupNamePrefix, $resourceGroupNameSuffix) {
  $resourceGroupName = $resourceGroupNamePrefix + $resourceGroupNameSuffix
  az group create --name $resourceGroupName --location $regionName --output "none"
  return $resourceGroupName
}

function Set-TemplateParameter ($templateParametersPath, $objectName, $propertyName, $propertyValue, $propertyIndex, $valueIsArray) {
  $valueReference = ($propertyName -eq "keyVault" -or $propertyName -eq "secretName") ? "reference" : "value"
  $templateParameters = Get-Content -Path $templateParametersPath -Raw | ConvertFrom-Json
  if ($propertyName -eq "") {
    $templateParameters.parameters.$objectName.$valueReference = $propertyValue
  } elseif ($propertyName.Contains(".")) {
    $propertyNames = $propertyName.Split(".")
    if ($propertyIndex -ge 0) {
      $templateParameters.parameters.$objectName.$valueReference.($propertyNames[0])[$propertyIndex].($propertyNames[1]) = $propertyValue
    } else {
      $templateParameters.parameters.$objectName.$valueReference.($propertyNames[0]).($propertyNames[1]) = $propertyValue
    }
  } else {
    if ($propertyIndex -ge 0) {
      if ($valueIsArray) {
        $templateParameters.parameters.$objectName.$valueReference[$propertyIndex].$propertyName = $propertyValue
      } else {
        $templateParameters.parameters.$objectName.$valueReference.$propertyName[$propertyIndex] = $propertyValue
      }
    } else {
      $templateParameters.parameters.$objectName.$valueReference.$propertyName = $propertyValue
    }
  }
  $templateParameters | ConvertTo-Json -Depth 10 | Out-File $templateParametersPath
}

function Set-ProvisioningToken ($iotEdgeConfigPath, $provisioningToken) {
  $iotEdgeConfig = Get-Content -Path $iotEdgeConfigPath -Raw | ConvertFrom-Json
  $iotEdgeConfig.modulesContent.avaedge."properties.desired".provisioningToken = $provisioningToken
  $iotEdgeConfig | ConvertTo-Json -Depth 10 | Out-File $iotEdgeConfigPath
}
