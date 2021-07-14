# Edge Video Analyzer ([aka.ms/eva](https://aka.ms/eva))

Edge Video Analyzer (EVA) is a modular set of parameterized [Azure Resource Manager (ARM)](https://docs.microsoft.com/azure/azure-resource-manager/management/overview) templates for the automated deployment of an end-to-end edge video AI solution in Microsoft Azure. Edge Video Analyzer provides a lightweight and customizable resource deployment framework based upon the [Azure Video Analyzer (AVA)](https://docs.microsoft.com/en-us/azure/azure-video-analyzer/video-analyzer-docs/overview) pipeline.

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
            <a href="https://docs.microsoft.com/en-us/azure/azure-video-analyzer/video-analyzer-docs/overview" target="_blank">Azure Video Analyzer</a>
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
        </td>
        <td>
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
        </td>
        <td>
    </tr>
</table>

## Deployment Modules

The Edge Video Analyzer solution is composed from the following Microsoft Azure resource templates.

| *Base Framework* | *IoT Solution* |
| :--------------- | :------------- |
| (01) [Virtual Network](BaseFramework/01.VirtualNetwork/Template.json) ([Parameters](BaseFramework/01.VirtualNetwork/Template.Parameters.json)) | (05) [Storage Account](IoTSolution/05.StorageAccount/Template.json) ([Parameters](IoTSolution/05.StorageAccount/Template.Parameters.json)) |
| (02) [Managed Identity](BaseFramework/02.ManagedIdentity/Template.json) ([Parameters](BaseFramework/02.ManagedIdentity/Template.Parameters.json)) | (06) [Time Series Insights](IoTSolution/06.TimeSeriesInsights/Template.json) ([Parameters](IoTSolution/06.TimeSeriesInsights/Template.Parameters.json)) |
| (03) [Key Vault](BaseFramework/03.KeyVault/Template.json) ([Parameters](BaseFramework/03.KeyVault/Template.Parameters.json)) | (07) [IoT Hub](IoTSolution/07.IoTHub/Template.json) ([Parameters](IoTSolution/07.IoTHub/Template.Parameters.json)) |
| (04) [Network Gateway](BaseFramework/04.NetworkGateway/Template.json) ([Parameters](BaseFramework/04.NetworkGateway/Template.Parameters.json)) | (08) [Video Analyzer](IoTSolution/08.VideoAnalyzer/Template.json) ([Parameters](IoTSolution/08.VideoAnalyzer/Template.Parameters.json)) |

For more information, contact Rick Shahid (rick.shahid@microsoft.com)
