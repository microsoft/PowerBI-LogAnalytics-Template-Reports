# Fabric Log Analytics for Analysis Services Engine report template

This template adds the model layer to the ocean of the Analysis Services engine trace events and enables you to go from data to insight to action quickly.

Download Power BI report template: [here](./FabricASEngineAnalytics.pbit)

## Setup

The following parameters are defined in the template:

|**Parameter**  |**Description**  |
|---------|---------|
|Azure Log Analytics Workspace Id |Globally unique identifier (GUID) of the Azure Log Analytics workspace containing the AS Engine trace events.|
|Days Ago To Start |Load data from the specified day to the time the call was initiated. The maximum value you can select is 30 days. However, your Premium capacity memory limits apply to this parameter. If those limits are exceeded, the template might fail to refresh. |
|Days Ago To Finish |Load data up to the specified number of days ago. Use 0 for today. |
|UTC Offset Hours|An hourly offset used to convert the data from Coordinate Universal Time (UTC) to a local time zone. |
|Fabric Workspace Id |Optionally enter a fabric workspace Id. |
|Fabric Item Id |Optionally enter a fabric artifact (semantic model) Id. |

![Screenshot of the Edit Parameters dialog.](./media/parameters.png)

## Report

### Data Model
The model has the following tables and the relationships:
* Calendar
  * 30s granularity.
  * Has columns like Date and Hour feed to the "Filters on all pages" section.
* Artifact
  * This is a calculated table based on the ExecutionMetrics table.
  * Has columns like WorkspaceId, WorkspaceName, ArtifactId/Semantic Model Id, ArtifactName/Semantic Model Name feed to the "Filters on all pages" section.
* ExecutionMetrics
  * This is a list of all the XmlaRequestId that has ExecutionMetrics and can associated with a semantic moded. Plus, the XmlaRequesstId can associated with a semantic model but no ExecutionMetrics (on-going refreshes or missing traces).
  * Has many to one relationshop to the Calendar and Artifiact tables.
  * Has the columns like CapacityId, XmlaRequestId, ApplicationName and EffectiveClaims/Identity feed to the "Filters on all pages" section.
* Command
  * This is a list of the XmalRequestId for data refreshes, as well as commands like backup, restore, deployment using the XMLA endpoint.
  * Has one to one relatinship to the ExecutionMetrics table.
  * Has the columns like OperationDetailName, RequestApp, RequestID, Status, StatusCode, CommandHash feed to the "Filter on this page" of the "Command/Refresh" page.
* Query
  * This is a list of the XmalRequestId for user queries.
  * Has one to one relationship to the ExecutionMetrics table.
  * Has the columns like OperationDetailName, RequestApp, RequestID, Status, StatusCode, QueryHash, DatasetId, ReportId, VisualId, DurationBucket, DatasetMode, ReplicaId feed to the "Filter on this page" of the "Query" page.
* Progress Report
  * Details of the data refresh at the table and partition level.
  * Has many to one relationship to the Command table.
  * Feeds to the "Command/Refresh" page and the Drill through page: "Refresh details".
   ![image](https://github.com/microsoft/PowerBI-LogAnalytics-Template-Reports/assets/167439901/3b671578-dfec-42bf-a734-d9ecf80f9564)

### Page: Overview

* Execution
  *  Dril down the chart to 30s granuality.
  *  From the Card visual Drill through to the "Query" or "Command/Refresh" page.
  *  From the Table visual Drill through to the "Query" or "Command/Refresh" page carrying the semantic model as a filter.
  ![image](https://github.com/microsoft/PowerBI-LogAnalytics-Template-Reports/assets/167439901/13678800-77c3-41c5-947e-74aebbba1308)

* Command/Refresh
  * For scheculed and on-demand refresh, the RequestID is coresponding to the Reques ID in the refresh history which can have multiple re-tries.
      
       ![image](https://github.com/microsoft/PowerBI-LogAnalytics-Template-Reports/assets/167439901/722789f5-5858-4d5b-aa4b-b275b27c65e0)

       ![image](https://github.com/microsoft/PowerBI-LogAnalytics-Template-Reports/assets/167439901/72cfebc0-6b21-4b51-929b-2266ddf06aae)

  * The StatusCode helps to group the refreshes with the same error. While it is not publicly documented, we can tell what it represents from the error message:
       
    ![image](https://github.com/microsoft/PowerBI-LogAnalytics-Template-Reports/assets/167439901/f98fd06c-0baf-42de-b700-acbfaaf843ed)


  * Expanding the semantic model table to view the partitions, selecting a partition to cross filter the table above as well as the column chart next to it. In the following example:
    * The selected partition is created by the incremental policy at 1am.
    * Scheduled to refresh every three hours and row processed keeps increasing.
    * Plus an addtional refresh at 1am the following day to to ensure partitions that are sliding from the incremental refresh window into the historical window (where they won’t be refreshed anymore) are going through a last refresh that ensures that they are up to date.
    * In total, this partition is refreshed 9 times while the semantic model is refreshed 70 times.
      ![image](https://github.com/microsoft/PowerBI-LogAnalytics-Template-Reports/assets/167439901/02a2fa39-0575-4df9-8879-7c26249177d8)

  * Scroll the table to the right to view the ExecuteSql and ReadData information in the table view that corresponding to the column chart.
      ![image](https://github.com/microsoft/PowerBI-LogAnalytics-Template-Reports/assets/167439901/43a1fb51-af4f-4123-a560-818a66203920)

  * Hover over or right click a XmlaRequestId to drill thorough to the Refresh detail page: use the Progres End time and the millisecond columns to figure out which partition failed first.
      ![image](https://github.com/microsoft/PowerBI-LogAnalytics-Template-Reports/assets/167439901/1b4a0185-c552-4785-8f1f-a1b8675ad957)

* Query
  * Review the Cpu and duration by ReportId, User, Query Type, StatusCode. For a high Cpu or duration query/XmlaRequestId, filter by the QueryHash to review the performance of the same query over the time.
    ![image](https://github.com/microsoft/PowerBI-LogAnalytics-Template-Reports/assets/167439901/b6f45191-4e80-469b-bcb9-722dfff9ecd6)

## Considerations and limitations

* Log Analytics Query Limits

  * Kusto has limits in terms of the number of records returned and the overall size of the data based on the query. For more information, see [Query Limits](https://learn.microsoft.com/azure/data-explorer/kusto/concepts/querylimits) and [Data is truncated](https://learn.microsoft.com/en-us/power-bi/connect-data/incremental-refresh-troubleshoot#problem-data-is-truncated).

  * If the template refresh fails or data is truncated due to the previously mentioned data limits, you can lower the amount of data retrieved from Log Analytics by reduce the date range and/or filter by a workspace or semantic model.
    
* Missing traces
  
  * It is possible traces are missing due to transient service interruption. For example, a XmlaReqeustId might has CommandBegin but no CommandEnd. As long as there are traces for the following refreshes we can treat it as missing trace, instead of a blocking issue.
