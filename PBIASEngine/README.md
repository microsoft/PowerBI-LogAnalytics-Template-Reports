# Power BI Log Analytics for Analysis Services Engine report template

This report allows you to visualize the activity of datasets hosted in the Analysis Services Engine in Power BI workspaces. You can use it to identify load patterns, investigate user actions, look at query performance trends, visualize refreshes, and much more! 

Download Power BI report template: [here](./PBIASEngine.pbit)

## Known Issues
- SE Duration measures are currently blank. This is because Vertipaq Storage Engine events are not yet supported in the Preview.
- If you find the report takes a very long time to refresh and appears to be stuck, try to load a shorter period of time. We have built the Power Query logic with Log analytics Query limits in mind, but it is possible you are hitting limits. Another thing to try is to go to the Regional Settings -> Locale in the template and change it to US date format. We have had reports of European customers having the report load blocked becuase of date conversion errors.

## Goals

The goal of the report template  is to build a tool that can be used to analyze AS Engine behavior in general and to help isolate and debug specific problems in depth. You can slice any operation by using CapacityId, Workspace Name, Dataset Name, and ReportId to give you the necessary context.

The following are some examples of questions that you can answer with this template.

### General

* What is the engine activity by capacity and workspace?
* What is the engine load by day or by hour?
* What operations are taking the most CPU time or duration?
* How does the load vary by hour of day?
* Which users are generating load?

### Query

* Which Data Analysis Expressions (DAX) queries were issued in a particular scope?
* Which queries are the most expensive?
* How does a unique DAX query vary over time, and which are the worst?
* What was the query text?
* What were the Storage Engine or DQ queries that were generated from a DAX query?
* How much time did the query spend in Storage Engine versus Formula Engine?
* Did queries use aggregations and what was the performance benefit?

### Refresh

* Which refreshes are expensive?
* Which refreshes overlap?
* Which operations within a refresh are in parallel, and which ones take the longest time?
* What were the different operations and suboperations within a refresh?

### Others

Since the template contains various AS Engine events, you can customize it to answer questions related to other events such as Discover or Notification.

## Data source

The template loads data from a single Azure Log Analytics workspace.

It doesn't matter if the Log Analytics workspace contains data from many Power BI workspaces. It also doesn't matter which level of administrator configured logging. The log schemas are exactly the same for every role, so there's only one version of the template. There are different levels of aggregation to accommodate a range of use cases. For more information, see [Using Log Analytics in Power BI](https://learn.microsoft.com/power-bi/transform-model/log-analytics/desktop-log-analytics-overview)

## App data model

The template has the following tables and relationships:

* User
* Query Duration Segment
* Scenario
* Calendar
* Time
* Operation
* Suboperation - Aggregations
* Suboperation - Query
* Suboperation - Refresh

The following image is an entity relationship (ER) diagram.

![Screenshot of the entity relationship diagram.](./media/er-diagram.png)

## App parameters

The following parameters are defined in the template:

|**Parameter**  |**Description**  |
|---------|---------|
|Days Ago To Start |Load data from the specified day to the time the call was initiated. The maximum value you can select is 30 days. However, your Premium capacity memory limits apply to this parameter. If those limits are exceeded, the template might fail to refresh.|
|Days Ago To Finish |Load data up to the specified number of days ago. Use 0 for today. |
|Log Analytics Table |Preset values corresponding to the Log Analytics source table:<br> - PowerBIDatasetsWorkspace<br> - PowerBIDatasetsTenant <br> Currently only PowerBIDatasetsWorkspace is supported. |
|Log Analytics WorkspaceId |Globally unique identifier (GUID) of the Azure Log Analytics workspace containing the AS Engine data. |
UTC Offset |An hourly offset used to convert the data from Coordinate Universal Time (UTC) to a local time zone. |
Pagination Hours | This parameter is optional. It describes the time window for each log analytics call from Power BI. You only need to update this parameter if you're running into failures while fetching data due to data size exceeding Log Analytics limits. |

![Screenshot of the Edit Parameters dialog.](./media/parameters.png)

## App usage

### App workflow

The following diagram shows the workflow for the template.

![Screenshot of a diagram showing the major pages of the template and some important available drillthroughs.](./media/template-app-as-engine-flow.png)

### Workspace summary

This page shows engine activities and load at a workspace level, focusing on identifying interesting datasets, reports, or users. You can use this page to identify a high-level issue to analyze further by navigating or drilling through to other pages of the template.

### Engine activities

This page provides engine load and activity trends by day and hour, with the ability to select a scenario such as Refresh Completed or Query Completed. You can drill through to the Engine activity detail page to get a look at a detailed list of each activity within the selected context.

### Engine activity detail

This page is a drillthrough page showing event-level data. For example, you can list all queries that ran in a particular time range.

### Dataset refreshes

This page provides a Gantt chart style view of refreshes to observe duration and parallelism. You can drill through to the dataset refresh details for more details.

### Dataset refresh detail

This drillthrough page shows the operations that occurred within a single dataset refresh. You can use this view to identify the longest running operation in a refresh and to see if there are any dependencies between activities.

### Query statistics

This page is an overview of query performance, highlighting typical and low performing durations and letting you see how variable each unique query is.

### Query detail

This drillthrough page shows visuals such as a detailed table for the query, a table for related queries, and more. For Import tables, the page shows you the internal Vertipaq storage engine queries and durations. For DirectQuery models, the page shows you the external queries, for example T-SQL sent to a SQL Server.

### Query history

This page shows you every execution of a query, provides CPU and duration stats, and provides trend visuals to see if there are any spikes.

### User activities

This page shows a summary view that focuses on users, helping you identify the most active users and those users who are experiencing worse performance relative to others.

### User detail

This drillthrough page provides details of the activities performed by a single user.

### Error summary

This page helps identify errors and spot any error trends.

### Error details

This page allows you to zoom in on a specific error by viewing the detailed event.

### Navigate in the app

The template contains a navigation bar at top of the page to navigate to the expected page.

![Screenshot of the navigation bar for the template.](./media/nav-bar.png)

Also, there's a back button on the top-left corner to go back to the previous page and an info icon that provides information about the page.

![Screenshot of the navigation bar highlighting the back and information buttons.](./media/info-and-back.png)

### Filter and understand the current context

Every page has a filter button below the navigation bar that you can select to open the pop-up filter panel and make selections.

![Screenshot highlighting the filter button at the top of the page on the template.](./media/filters.png)

The current values of the filters are displayed in the smart narrative next to the filters button. You can clear all the slicers by using the **Clear** button on the top-left corner or close the window by using the **X** button in the top-right corner.

![Screenshot of the popup dialog for the filter.](./media/pop-up-filter.png)

![Screenshot of smart narrative next to the filter button.](./media/smart-narrative.png)

>If more than one value is selected for a filter, the smart narrative displays one of the values followed by "and more".

## Datasets template pages

* [Workspace Summary](#page-workspace-summary)
* [Engine Activities](#page-engine-activities-also-a-drillthrough)
* [Engine Activity Details](#drillthrough-page-engine-activity-details)
* [Dataset Refreshes](#page-dataset-refreshes-also-a-drillthrough)
* [Dataset Refresh Detail](#drillthrough-page-dataset-refresh-detail)
* [Query Statistics](#page-query-statistics-also-a-drillthrough)
* [Query Detail](#drillthrough-page-query-detail)
* [Query History](#drillthrough-page-query-history)
* [User Activities](#page-user-activities)
* [User Detail](#drillthrough-page-user-detail)
* [Error Summary](#page-error-summary)
* [Error Detail](#drillthrough-page-error-page-detail)
* [Help](#help)

### Page: Workspace summary

This page is targeted at a workspace administrator and shows activities and statistics related to datasets and queries. It also identifies top reports by load, details popular datasets by operations or users, and allows drillthrough to various pages to get further details.

![Screenshot of the Workspace summary page in the template.](./media/workspace-summary.png)

The following table lists the visuals displayed on the workspace summary page according to their location on the page.

|Left  | Right  |
|---------|---------|
|**Top N reports with high CPU Usage** - A bar chart shows Top N reports with high aggregate CPU usage by default. <br> **Top N users with high CPU Usage** - A bar chart shows Top N users with high aggregate CPU usage by default. |**Top 10 datasets by query executions** - A table shows 10 datasets by query executions in descending order. <br> **Reports by slow queries** - A scatter chart shows the query performance distribution. |
|**Dataset refresh success versus failures** - A column chart shows number of successful versus failed dataset refreshes per day. |**Queries by duration** - A column chart shows the count of queries by duration band.
|**Queries by date and duration segments** - A clustered column chart shows query count by query duration distribution per day. | |

### Page: Engine activities (also a drillthrough)

This page provides a trend overview of AS Engine activities by day and by hour. It allows you to identify peaks or outliers on a day and then see how that activity breaks down by hour when you cross-highlight by selecting a day.

![Screenshot of the Engine activities page in the template.](./media/engine-activities.png)

The following table lists the visuals displayed on the engine activities page according to their location on the page.

|Left  | Right  |
|---------|---------|
|**CPU time (s) and count of operation by date and scenario** - Columns show the total CPU time taken per day by each operation type. | **Engine activity details** - A table is represented in stepped layout as a hierarchy across capacities, workspaces, datasets, and reports, showing a count of operations, CPU time, and durations. |
| **CPU time (s) and count of operations by hour and scenario** - Columns show the total CPU time taken per hour by each operation type. | |

### Drillthrough page: Engine activity details

This page allows you to focus on a narrow time range and see the individual activities at a granular level of detail. The following example shows all the DAX queries that were executed in a minute, sorted by longest duration.

![Screenshot of the Engine Activity Details drillthrough.](./media/engine-activity-details.png)

The following table lists the visuals displayed on the engine activity details page according to their location on the page.

| Visuals  |
|---------|
|**CPU time (s) and count of operations by scenarios over period of time** - A column chart shows the total CPU time taken by each scenario per day. |
|**Operations** - A table shows the detail of operations. |

### Page: Dataset refreshes (also a drillthrough)

This page provides an overview of dataset refreshes occurring over a selected period. It allows you to identify long running refreshes and visualize which ones are happening in parallel. This page allows you to select any data refresh and drill through to a page called **Dataset refresh detail**.

![Screenshot of the Dataset refreshes page in the template.](./media/dataset-refreshes.png)

The following table lists the visuals displayed on the dataset refreshes page according to their location on the page.

| Visuals |
|---------|
|**Duration (ms) by refresh and start date/time** - A column chart shows the refresh duration for datasets over a period of time.|
| **Dataset refresh timeline** - A timeline visual shows refreshes per dataset over a period of time.|
| **Dataset refresh operations** - A table shows details for the refresh operations.|

### Drillthrough page: Dataset refresh detail

This page allows you to visualize a single dataset refresh in detail. You can see all the internal operations that the engine performed such as executing queries and compressing data. It allows you to determine the longest running operations, which are parallel, and which might have dependencies.

![Screenshot of the Dataset refresh detail drillthrough.](./media/dataset-refresh-detail.png)

The following table lists the visuals displayed on the dataset refresh detail page according to their location on the page.

| Visuals  |
|---------|
|**Data refresh suboperation timeline by object and event subclass** - A timeline of each corresponding dataset refresh suboperation is displayed. |
| **Dataset refresh suboperations** - A table shows details of the suboperations that the engine performs for each refresh. |

### Page: Query statistics (also a drillthrough)

This page focuses on queries in bulk. The goal is to identify which queries are common and which queries have high variability. The template provides percentiles and deviations to give you an idea of both typical and more extreme measurements.

Any query can be drilled through to a page called **Query detail** to see details about its execution. Among other pieces of information, you can see the internal Vertipaq Queries or external DirectQuery text and duration depending on the model type.

You can also drill through to a page called **Query history** that shows you all the execution of that query over a period, and its performance trend.

![Screenshot of the Query statistics page in the template.](./media/query-statistics.png)

The following table lists the visuals displayed on the query statistics page according to their location on the page.

|Left  | Right  |
|---------|---------|
|**Query success versus failures count** - A Line chart shows the daily trend of query completions and failures. |**Queries by aggregation usage** - Shows how many queries used aggregations by using both count and percentage. |
|**Queries by date and segments** - A clustered column chart shows query count by query duration segment. | |
|**Top N queries by CPU variability** - A table is represented in stepped layout as a hierarchy across capacities, workspaces, datasets, reports, and queries showing the count of operations, CPU time standard deviation, and more. <br>**Top N queries by duration P50** - A table is represented in stepped layout as a hierarchy across capacities, workspaces, datasets, reports, and queries showing the count of operations, duration standard deviation, and more.||

### Drillthrough page: Query detail

This page provides a detailed look at a single execution of a DAX query. Depending on whether the query was for an Import or DirectQuery model, you might either see the internal Vertipaq Storage Engine queries or the external DQ source queries (for example, T-SQL for SQL Server). It also identifies which aggregations were used, if any.

![Screenshot of the Query detail drillthrough.](./media/query-detail.png)

The following table lists the visuals displayed on the query detail page according to their location on the page.

|Left  | Right  |
|---------|---------|
|**Query executions** - A table lists each query executed, with performance details. |**Event Text** - Table shows the complete event text for queries executed. |
|**CPU time (s) by date and time** - A line chart shows total CPU time taken in seconds depending on whether aggregation is used or not over a time period. <br> **Duration (ms) by date and time** - A line chart shows total duration taken in seconds depending on whether aggregation is used or not over a time period. |  |

The cards on the right display the number of users who ran this query and the application that was used to run this query.

### Drillthrough page: Query history

This page is a historical view of a single unique query. It shows metrics over time and introduces the Storage Engine and Formula Engine time. You can use it to determine how consistent a query is over time and identify if issues are isolated to particular users or time frames.

![Screenshot of the Query history drillthrough.](./media/query-history.png)

The following table lists the visuals displayed on the query history page according to their location on the page.

|Left  | Right  |
|---------|---------|
|**Query details** - Lists each query executed with performance details.
|**CPU time (s) by date and time** - A line chart shows total CPU time taken over seconds depending on whether aggregation is used or not over a time period. | **Event text** - A table shows the complete complete event text for queries. |

The cards on the right display the total number of executions of a given query, the execution times in ms, and the aggregation utilization percentage.

### Page: User activities

This page gives an overview of the user activities across the workspace. It also gives information about the most active users for a period by capturing their CPU time usage, query usage, and operations performed.

![Screenshot of the User activities page in the template.](./media/user-activities.png)

The following table lists the visuals displayed on the user activities page according to their location on the page.

|Left  | Right  |
|---------|---------|
|**Top N users by operation** - Shows the top 5 users who performed the most operations against the dataset. <br>**Top N users by query execution** - Shows the top 5 users who ran the most queries against the dataset. |**Queries versus CPU time by users** - Compares query count versus Avg CPU time for each unique query text. |
| **Daily user and operation count** - Columns show the count of users, and the line shows operation count, both by day. | **Hourly user and operation count** - A column chart represents the users as columns and operation count over the time as hourly trend for users.
|**User details** - Shows a count of actions and artifacts per user. | |

The cards on the right display user count and operations count.

### Drillthrough page: User detail

This page provides a detailed historical view of activities for a single user.

![Screenshot of the User detail drillthrough.](./media/user-detail.png)

The following table lists the visuals displayed on the user detail page according to their location on the page.

|Left  | Right  |
|---------|---------|
|**CPU time (s), count of operations and users by date** - Columns show the total CPU time taken per day by each operation type. The line shows the count of operations for a day. |**CPU time (s), count of operations and earliest date by hour and scenario** - This hourly breakdown complements the daily version of the chart.|
|**User details** - A table shows the user activities sorted by timestamp.|

### Page: Error summary

This page provides an overview of errors or failed executions over time, allowing you to view individual operations that reported an error status.

![Screenshot of the Error summary page in the template.](./media/error-summary.png)

The following table lists the visuals displayed on the error summary page according to their location on the page.

|Left  | Right  |
|---------|---------|
|**Total query failed and query failure rate by date** - Columns show the total failed queries. Line values represent the query failure rate. <br>**Total failed refreshes and refresh - failure rate by date** - Columns show the total failed dataset refreshes. Line values represent the dataset refresh failure rate. The visual shows both by day. |**Failure details** - A table shows the details of failure with respect to the total values.|
|**Error details** - Lists errors reported by datasets for any operation.||

The cards on the right display overall operations count, query failure count, refresh failure count, and user count.

### Drillthrough page: Error page detail

This page provides details of errors generated by the engine. It also provides the information about failed operations due to query failures.

![Screenshot of the Error page drillthrough.](./media/error-detail.png)

The following table lists the visuals displayed on the error detail page according to their location on the page.

| Visuals  |
|---------|
|**CPU time (ms) total and count of operations by date, hour and scenario** - Line and column charts show the trends for the scenario on the day, distributed by CPU time taken for each scenario in stacked column series.|
|**Operations** - A table lists all operations performed on the dataset.|

### Help

This page provides a help summary of different features throughout the template. It also has support links that can be used for any support assistance.

![Screenshot of the Help page that's in the template.](./media/help.png)


>Each visual in the template has a **?** icon. Select this icon to learn more about the visual.

## Considerations and limitations

* Log Analytics Query Limits

  * Kusto has limits in terms of the number of records returned and the overall size of the data based on the query. The template has been built to work around these limits by pulling data in sequential chunks. However, you might still exceed these limits, resulting in a refresh failure in the template. For more information, see [Query Limits](https://learn.microsoft.com/azure/data-explorer/kusto/concepts/querylimits).

  * If the template refresh fails due to the previously mentioned data limits, you can configure the Pagination Hours parameter. Setting a lower value here lowers the amount of data retrieved from Log Analytics per call by increasing the number of calls.

* The following events are intentionally excluded from Log Analytics during the Preview:
  
  * ProgressReportCurrent
  * ProgressReportBegin
  * ProgressReportError
  * VertipaqSEQueryBegin
  * VertipaqSEQueryEnd

  Due to this design decision, storage engine subqueries aren't visible for now on the Query detail page.
