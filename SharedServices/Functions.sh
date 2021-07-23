function New-TraceMessage {
  moduleName=$1
  moduleEnd=$2
  traceMessage=$(date +%H:%M:%S)
  if [ $moduleEnd == true ]; then
    traceMessage+="   END"
  else
    traceMessage+=" START"
  fi
  echo "$traceMessage $moduleName"
}

function Get-PropertyValue {
  objectData=$1
  propertyFilter=$2
  disableRawOutput=$3
  jqOptions=$([ "$disableRawOutput" == true ] && echo "-c" || echo "-cr")
  echo $(echo "$objectData" | jq $jqOptions $propertyFilter)
}

function Set-ResourceGroup {
  regionName=$1
  resourceGroupNamePrefix=$2
  resourceGroupNameSuffix=$3
  resourceGroupName="$resourceGroupNamePrefix$resourceGroupNameSuffix"
  az group create --name $resourceGroupName --location $regionName --output "none"
  echo $resourceGroupName
}

function Set-TemplateParameter {
  templateParametersPath=$1
  objectName=$2
  propertyName=$3
  propertyValue=$4
  propertyIndex=$5
  valueIsArray=$6
  if [[ $propertyValue != \"*\" && $propertyValue != \{*\} && $propertyValue != \[*\] ]]; then
    propertyValue=\"$propertyValue\"
  fi
  valueReference=$([[ $propertyName == "keyVault.id" || $propertyName == "secretName" ]] && echo "reference" || echo "value")
  if [ "$propertyName" == "" ]; then
    templateParameters=$(jq .parameters.$objectName.$valueReference=$propertyValue $templateParametersPath)
  elif [[ $propertyName == *.* ]]; then
    IFS="."
    read -ra propertyNames <<< "$propertyName"
    unset IFS
    if [ "$propertyIndex" != "" ]; then
      templateParameters=$(jq .parameters.$objectName.$valueReference.${propertyNames[0]}[$propertyIndex].${propertyNames[1]}=$propertyValue $templateParametersPath)
    else
      templateParameters=$(jq .parameters.$objectName.$valueReference.${propertyNames[0]}.${propertyNames[1]}=$propertyValue $templateParametersPath)
    fi
  else
    if [ "$propertyIndex" != "" ]; then
      if [ $valueIsArray == true ]; then
        templateParameters=$(jq .parameters.$objectName.$valueReference[$propertyIndex].$propertyName=$propertyValue $templateParametersPath)
      else
        templateParameters=$(jq .parameters.$objectName.$valueReference.$propertyName[$propertyIndex]=$propertyValue $templateParametersPath)
      fi
    else
      templateParameters=$(jq .parameters.$objectName.$valueReference.$propertyName=$propertyValue $templateParametersPath)
    fi
  fi
  echo "$templateParameters" > $templateParametersPath
}

function Set-ProvisioningToken {
  iotEdgeConfigPath=$1
  provisioningToken=$2
  iotEdgeConfig=$(jq .modulesContent.avaedge'."properties.desired"'.provisioningToken=$provisioningToken $iotEdgeConfigPath)
  echo "$iotEdgeConfig" > $iotEdgeConfigPath
}
