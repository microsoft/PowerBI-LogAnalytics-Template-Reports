#Requires -Modules MicrosoftPowerBIMgmt

param(
    $workspaces = @("<WorkspaceId>", "<WorkspaceId>")
    ,
    $logAnalyticsConfig = @{subscriptionId = "<Azure Subscription Id>"; resourceGroup = "<Azure Resource Group Name"; resourceName = "<Azure Log Analytics Resource Name>" }
)

try { Get-PowerBIAccessToken | out-null } catch { Connect-PowerBIServiceAccount }

foreach ($workspaceId in $workspaces) {

    Write-Host "Getting workspace info '$workspaceId'"

    # Get workspace information (https://learn.microsoft.com/en-us/rest/api/power-bi/admin/groups-get-group-as-admin)

    $workspace = Invoke-PowerBIRestMethod -url "admin/groups/$workspaceId" -Method Get | ConvertFrom-Json

    $bindFlag = $true

    # Checks if there is already a Log Analytics connected and if its the same we want to connect.

    if ($workspace.logAnalyticsWorkspace) {   
        if ($workspace.logAnalyticsWorkspace.subscriptionId -ieq $logAnalyticsConfig.subscriptionId -and $workspace.logAnalyticsWorkspace.resourceGroup -ieq $logAnalyticsConfig.resourceGroup -and $workspace.logAnalyticsWorkspace.resourceName -ieq $logAnalyticsConfig.resourceName) {
            Write-Host "Already connected to target Log Analytics '$($logAnalyticsConfig.resourceName)'"
            $bindFlag = $false
        }
        else {
            
            # Disconnect from the current Log analytics, just for demonstration on how to do it. The API handles the detatch and attach when assigning a new Log Analytics Workspace.
            # https://learn.microsoft.com/en-us/rest/api/power-bi/admin/groups-update-group-as-admin

            Write-Host "Disconnecting workspace from Log Analytics '$($workspace.logAnalyticsWorkspace.resourceName)'"

            $body = @{
                logAnalyticsWorkspace = $null
            }

            Invoke-PowerBIRestMethod -url "admin/groups/$workspaceId" -Method Patch -Body ($body | ConvertTo-Json)
                        
        }
    }

    # If there is no Log Analytics connected to the Power BI workspace or its different execute the workspace PATCH api to connect the workspace to Log Analytics
    # https://learn.microsoft.com/en-us/rest/api/power-bi/admin/groups-update-group-as-admin
    
    if ($bindFlag) {
        Write-Host "Binding to Log Analytics '$($logAnalyticsConfig.resourceName)'"

        $body = @{
            logAnalyticsWorkspace = $logAnalyticsConfig
        }        

        Invoke-PowerBIRestMethod -url "admin/groups/$workspaceId" -Method Patch -Body ($body | ConvertTo-Json)
    }
}
