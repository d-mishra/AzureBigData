<#

.DESCRIPTION
	Creates a new Resource Group if it does not already exist

.NOTES
	Created by Mark Vaillancourt, Microsoft, 2016-08-03

#>

$scriptStartTime = (Get-Date)

Write-Output "Script Start Time: $scriptStartTime"

$rootNameValue ="Solution Root Name Value Placeholder"

# Resolve Asset names based on pocRootNameValue

$locationVariable = "$($rootNameValue)LocationName"
$storageAccountNameVariable = "$($rootNameValue)StorageAccountName"
$subscriptionIDVariable = "$($rootNameValue)AzureSubscriptionID"
$resourceGroupNameVariable = "$($rootNameValue)ResourceGroupName"
$clusterNameVariable = "$($rootNameValue)ClusterName"
$hiveMetastoreDBNameVariable = "$($rootNameValue)HiveMetastoreDBName"
$sqlServerNameVariable = "$($rootNameValue)SQLServerName"
$clusterHeadNodeSizeVariable = "$($rootNameValue)ClusterHeadNodeSize"
$clusterWorkerNodeSizeVariable = "$($rootNameValue)ClusterWorkerNodeSize"
$clusterWorkerNodeCountVariable = "$($rootNameValue)ClusterWorkerNodeCount"
$clusterVersionVariable = "$($rootNameValue)ClusterVersion"
$clusterStorageContainerVariable = "$($rootNameValue)ClusterStorageContainerName"
$clusterHTTPCredentialVariable = "$($rootNameValue)hdpuser"
$clusterSSHCredentialVariable = "$($rootNameValue)sshuser"
$sqlServerAdminCredentialVariable = "$($rootNameValue)sqluser"
$warehouseNameVariable = "$($rootNameValue)sqlDWName"
$analysisServicesServerNameVariable = "$($rootNameValue)AnalysisServicesServerName"


$location = Get-AutomationVariable -Name $locationVariable	
$storageAccountName = Get-AutomationVariable -Name $storageAccountNameVariable
$subscriptionID = Get-AutomationVariable -Name $subscriptionIDVariable
$resourceGroupName = Get-AutomationVariable -Name $resourceGroupNameVariable
$clusterName = Get-AutomationVariable -Name $clusterNameVariable
$hiveMetastoreDBName = Get-AutomationVariable -Name $hiveMetastoreDBNameVariable
$sqlServerName = Get-AutomationVariable -Name $sqlServerNameVariable
$clusterHeadNodeSize = Get-AutomationVariable -Name $clusterHeadNodeSizeVariable
$clusterWorkerNodeSize = Get-AutomationVariable -Name $clusterWorkerNodeSizeVariable
$clusterWorkerNodeCount = Get-AutomationVariable -Name $clusterWorkerNodeCountVariable
$clusterVersion = Get-AutomationVariable -Name $clusterVersionVariable
$clusterStorageContainer = Get-AutomationVariable -Name $clusterStorageContainerVariable
$clusterHTTPCredential = Get-AutomationPSCredential -Name $clusterHTTPCredentialVariable
$clusterSSHCredential = Get-AutomationPSCredential -Name $clusterSSHCredentialVariable
$sqlServerAdminCredential = Get-AutomationPSCredential -Name $sqlServerAdminCredentialVariable
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

"Calling NewHDInsightHadoopCluster Runbook to create HDinsight Hadoop cluster..."
.\ChildNewHDInsightHadoopCluster.ps1 `
		-Location $location `
		-StorageAccountName $storageAccountName `
		-SubscriptionId $subscriptionID `
		-ResourceGroupName $resourceGroupName `
		-ClusterName $clusterName `
		-SqlAzureDatabaseName $hiveMetastoreDBName `
		-SqlAzureServerName $sqlServerName `
		-HeadNodeSize $clusterHeadNodeSize `
		-WorkerNodeSize $clusterWorkerNodeSize `
		-ClusterType "Hadoop" `
		-ClusterSizeInNodes $clusterWorkerNodeCount `
        -ClusterVersion $clusterVersion `
		-DefaultStorageContainerName $clusterStorageContainer `
		-ClusterHTTPCredential $clusterHTTPCredential `
		-ClusterSSHCredential $clusterSSHCredential `
		-SqlAzureServerCredential $sqlServerAdminCredential

"Calling ResumeSQLDataWarehouse Runbook to Resume the Warehouse..."
.\ChildResumeSQLDataWarehouse.ps1 `
    -SubscriptionId $subscriptionID `
    -ResourceGroupName $resourceGroupName `
    -WarehouseName $warehouseName `
    -ServerName $sqlServerName 

"Calling ResumeAzureAnalysisServicesServer Runbook to Resume Azure Analysis Services Server..."
.\ChildResumeAzureAnalysisServicesServer.ps1 `
    -SubscriptionId $subscriptionID `
    -ResourceGroupName $resourceGroupName `
    -analysisServicesServerName $analysisServicesServerName 

$scriptEndTime = (Get-Date)

Write-Output "Script End Time: $scriptEndTime"

$scriptExecutionDuration = New-TimeSpan -Start $scriptStartTime -End $scriptEndTime

$scriptExecutionDurationHours = $scriptExecutionDuration.Hours
$scriptExecutionDurationMinutes = $scriptExecutionDuration.Minutes
$scriptExecutionDurationSeconds = $scriptExecutionDuration.Seconds

Write-Output "Total script execution duration: $scriptExecutionDurationHours : $scriptExecutionDurationMinutes : $scriptExecutionDurationSeconds"
