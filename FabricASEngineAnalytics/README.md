# Fabric Log Analytics for Analysis Services Engine report template

TODO: Overview description

Download Power BI report template: [here](./FabricASEngineAnalytics.pbit)

## Setup


The following parameters are defined in the template:

|**Parameter**  |**Description**  |
|---------|---------|
|Azure Log Analytics Workspace Id |Globally unique identifier (GUID) of the Azure Log Analytics workspace containing the AS Engine data.|
|Days Ago To Start |Load data from the specified day to the time the call was initiated. The maximum value you can select is 30 days. However, your Premium capacity memory limits apply to this parameter. If those limits are exceeded, the template might fail to refresh. |
|Days Ago To Finish |Load data up to the specified number of days ago. Use 0 for today. |
|UTC Offset Hours|An hourly offset used to convert the data from Coordinate Universal Time (UTC) to a local time zone. |
|Fabric Workspace Id |TODO |
|Fabric Item Id |TODO |

![Screenshot of the Edit Parameters dialog.](./media/parameters.png)

## Report

### Page: Overview

TODO: Brief detail of each page, how to interact and type of analysis

## Considerations and limitations

TODO: Add any limitations/considerations that apply
