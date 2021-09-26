# Edge Video Analyzer ([aka.ms/eva](https://aka.ms/eva))

The Edge Video Analyzer (EVA) solution is a modular set of parameterized [Azure Resource Manager (ARM)](https://docs.microsoft.com/azure/azure-resource-manager/management/overview) templates for automated deployment of an end-to-end [Azure IoT Edge](https://docs.microsoft.com/en-us/azure/iot-edge/about-iot-edge) video AI pipeline. Edge Video Analyzer (EVA) provides a lightweight and customizable resource deployment framework based upon the [Azure Video Analyzer (AVA)](https://docs.microsoft.com/en-us/azure/azure-video-analyzer/video-analyzer-docs/overview) platform.

[Test Heading](/#test-heading)

## Solution Architecture

The following overview diagram depicts the Edge Video Analyzer solution architecture.

![](https://docs.microsoft.com/en-us/azure/azure-video-analyzer/video-analyzer-docs/media/overview/product-diagram.svg)

The Edge Video Analyzer solution integrates the following Microsoft Azure services.

<table>
    <tr>
        <td>
            <a href="https://docs.microsoft.com/azure/virtual-network/virtual-networks-overview" target="_blank">Azure Virtual Network</a>
        </td>
        <td>
            <a href="https://docs.microsoft.com/azure/key-vault/key-vault-overview" target="_blank">Azure Key Vault</a>
        </td>
        <td>
            <a href="https://docs.microsoft.com/azure/storage" target="_blank">Azure Storage</a>
        </td>
        <td>
            <a href="https://docs.microsoft.com/en-us/azure/iot-dps/about-iot-dps" target="_blank">Azure IoT Hub Device Provisioning</a>
        </td>
    </tr>
    <tr>
        <td>
            <a href="https://docs.microsoft.com/azure/vpn-gateway/vpn-gateway-about-vpngateways" target="_blank">Azure Virtual Network Gateway</a>
        </td>
        <td>
            <a href="https://docs.microsoft.com/azure/private-link/private-link-overview" target="_blank">Azure Private Link</a>
        </td>
        <td>
            <a href="https://docs.microsoft.com/en-us/azure/time-series-insights/overview-what-is-tsi" target="_blank">Azure Time Series Insights</a>
        </td>
        <td>
            <a href="https://docs.microsoft.com/en-us/azure/azure-video-analyzer/video-analyzer-docs/overview" target="_blank">Azure Video Analyzer</a>
        </td>
    </tr>
    <tr>
        <td>
            <a href="https://docs.microsoft.com/azure/active-directory/managed-identities-azure-resources/overview" target="_blank">Azure Managed Identity</a>
        </td>
        <td>
            <a href="https://docs.microsoft.com/azure/dns/private-dns-overview" target="_blank">Azure Private DNS</a>
        </td>
        <td>
            <a href="https://docs.microsoft.com/en-us/azure/iot-hub/about-iot-hub" target="_blank">Azure IoT Hub</a>
        </td>
        <td>
            <a href="https://docs.microsoft.com/en-us/azure/media-services/latest/media-services-overview" target="_blank">Azure Media Services</a>
        </td>
    </tr>
</table>

## Deployment Modules

The Edge Video Analyzer solution is composed from the following Microsoft Azure resource templates.

| *Shared Services* | *IoT Framework* | *Edge Pipeline* |
| :---------------- | :-------------- | :-------------- |
| (00) [Monitor Telemetry](SharedServices/00.MonitorTelemetry/Template.json) ([Parameters](SharedServices/00.MonitorTelemetry/Template.Parameters.json)) | (05) [Storage Account](IoTFramework/05.StorageAccount/Template.json) ([Parameters](IoTFramework/05.StorageAccount/Template.Parameters.json)) | (09) [Video Analyzer](EdgePipeline/09.VideoAnalyzer/Template.json) ([Parameters](EdgePipeline/09.VideoAnalyzer/Template.Parameters.json)) |
| (01) [Virtual Network](SharedServices/01.VirtualNetwork/Template.json) ([Parameters](SharedServices/01.VirtualNetwork/Template.Parameters.json)) | (06) [Time Series Insights](IoTFramework/06.TimeSeriesInsights/Template.json) ([Parameters](IoTFramework/06.TimeSeriesInsights/Template.Parameters.json)) | (10) [Media Services](EdgePipeline/10.MediaServices/Template.json) ([Parameters](EdgePipeline/10.MediaServices/Template.Parameters.json)) |
| (02) [Managed Identity](SharedServices/02.ManagedIdentity/Template.json) ([Parameters](SharedServices/02.ManagedIdentity/Template.Parameters.json)) | (07) [IoT Hub](IoTFramework/07.IoTHub/Template.json) ([Parameters](IoTFramework/07.IoTHub/Template.Parameters.json)) | |
| (03) [Key Vault](SharedServices/03.KeyVault/Template.json) ([Parameters](SharedServices/03.KeyVault/Template.Parameters.json)) | (08) [IoT Device](IoTFramework/08.IoTDevice/Template.json) ([Parameters](IoTFramework/08.IoTDevice/Template.Parameters.json)) | |
| (04) [Network Gateway](SharedServices/04.NetworkGateway/Template.json) ([Parameters](SharedServices/04.NetworkGateway/Template.Parameters.json)) | | |

For more information, contact Rick Shahid (rick.shahid@microsoft.com)

#Test Heading

TBD
