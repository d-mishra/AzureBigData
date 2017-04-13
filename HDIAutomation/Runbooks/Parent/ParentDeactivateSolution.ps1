<#

.DESCRIPTION
	Removes an HDInsight cluster if it exists

.NOTES
	Created by Mark Vaillancourt, Microsoft, 2016-08-03

#>

$scriptStartTime = (Get-Date)

Write-Output "Script Start Time: $scriptStartTime"

$rootNameValue ="Solution Root Name Value Placeholder"

# Resolve Asset names based on pocRootNameValue

$subscriptionIDVariable = "$($rootNameValue)AzureSubscriptionID"
$resourceGroupNameVariable = "$($rootNameValue)ResourceGroupName"
$clusterNameVariable = "$($rootNameValue)ClusterName"
$sqlServerNameVariable = "$($rootNameValue)SQLServerName"
$warehouseNameVariable = "$($rootNameValue)sqlDWName"
$analysisServicesServerNameVariable = "$($rootNameValue)AnalysisServicesServerName"

$subscriptionID = Get-AutomationVariable -Name $subscriptionIDVariable
$resourceGroupName = Get-AutomationVariable -Name $resourceGroupNameVariable
$clusterName = Get-AutomationVariable -Name $clusterNameVariable
$sqlServerName = Get-AutomationVariable -Name $sqlServerNameVariable
$warehouseName = Get-AutomationVariable -Name $warehouseNameVariable
$analysisServicesServerName = Get-AutomationVariable -Name $analysisServicesServerNameVariable


$connectionName = "AzureRunAsConnection"
    
try
{
    # Get the connection "AzureRunAsConnection "
    $servicePrincipalConnection=Get-AutomationConnection -Name $connectionName         

    "Logging in to Azure..."
    Add-AzureRmAccount `
        -ServicePrincipal `
        -TenantId $servicePrincipalConnection.TenantId `
        -ApplicationId $servicePrincipalConnection.ApplicationId `
        -CertificateThumbprint $servicePrincipalConnection.CertificateThumbprint 
}
catch {
    if (!$servicePrincipalConnection)
    {
        $ErrorMessage = "Connection $connectionName not found."
        throw $ErrorMessage
    } else{
        Write-Error -Message $_.Exception
        throw $_.Exception
    }
}

"Selecting Azure Subscription..."
Select-AzureRmSubscription -Subscriptionid $subscriptionID

"Calling PauseSQLDataWarehouse Runbook to Pause the Warehouse..."
.\ChildPauseSQLDataWarehouse.ps1 `
    -SubscriptionId $subscriptionID `
    -ResourceGroupName $resourceGroupName `
    -WarehouseName $warehouseName `
    -ServerName $sqlServerName 		

"Calling PauseAzureAnalysisServicesServer Runbook to Pause Azure Analysis Services Server..."
.\ChildPauseAzureAnalysisServicesServer.ps1 `
    -SubscriptionId $subscriptionID `
    -ResourceGroupName $resourceGroupName `
    -analysisServicesServerName $analysisServicesServerName 

"Removing HDInsight Cluster..."
.\ChildRemoveHDInsightCluster.ps1 `
		-SubscriptionId $subscriptionID `
		-ResourceGroupName $resourceGroupName `
		-ClusterName $clusterName

$scriptEndTime = (Get-Date)

Write-Output "Script End Time: $scriptEndTime"

$scriptExecutionDuration = New-TimeSpan -Start $scriptStartTime -End $scriptEndTime

$scriptExecutionDurationHours = $scriptExecutionDuration.Hours
$scriptExecutionDurationMinutes = $scriptExecutionDuration.Minutes
$scriptExecutionDurationSeconds = $scriptExecutionDuration.Seconds

Write-Output "Total script execution duration: $scriptExecutionDurationHours : $scriptExecutionDurationMinutes : $scriptExecutionDurationSeconds"





