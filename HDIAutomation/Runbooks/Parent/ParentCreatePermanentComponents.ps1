<#

.DESCRIPTION
	Creates Azure components to form foundation of solution, except HDInsight cluster
    This objects created include
        -- Resource Group
        -- Storage Account
        -- Storage Container for Cluster
        -- Storage Container for Raw data files
        -- SQL Database Server
        -- SQL Database Server Firewall Rules
        -- SQL Database for Hive Metastore for Cluster
        -- SQL Data Warehouse
        -- Azure Analysis Services server


.NOTES
	Created by Mark Vaillancourt, Microsoft, 2016-08-03

.PARAMETER

#>

$scriptStartTime = (Get-Date)

Write-Output "Script Start Time: $scriptStartTime"

$rootNameValue ="Solution Root Name Value Placeholder"

# Resolve Asset names based on pocRootNameValue
$resourceGroupNameVariable = "$($rootNameValue)ResourceGroupName"
$locationVariable = "$($rootNameValue)LocationName"
$subscriptionIDVariable = "$($rootNameValue)AzureSubscriptionID"
$storageAccountNameVariable = "$($rootNameValue)StorageAccountName"
$storageAccountTypeVariable = "$($rootNameValue)StorageAccountType"
$clusterStorageContainerVariable = "$($rootNameValue)ClusterStorageContainerName"
$rawFilesStorageContainerVariable = "$($rootNameValue)RawFileContainerName"
$sqlServerNameVariable = "$($rootNameValue)SQLServerName"
$sqlServerVersionVariable = "$($rootNameValue)SQLServerVersion"
$sqlAdminCredentialsVariable = "$($rootNameValue)sqluser"
$sqlServerIPFirewallRuleNameVariable = "$($rootNameValue)SQLServerIPFirewallRuleName"
$sqlServerIPFirewallRuleStartIPVariable = "$($rootNameValue)SQLServerIPFirewallRuleStartIP"
$sqlServerIPFirewallRuleEndIPVariable = "$($rootNameValue)SQLServerIPFirewallRuleEndIP"
$hiveMetastoreDBNameVariable = "$($rootNameValue)HiveMetastoreDBName"
$hiveMetastoreDBEditionVariable = "$($rootNameValue)HiveMetastoreDBEditionName"
$hiveMetastoreDBServiceObjectiveVariable = "$($rootNameValue)HiveMetastoreDBRequestedServiceObjectiveName"
$warehouseServiceObjectiveVariable = "$($rootNameValue)sqlDWRequestedServiceObjectiveName"
$warehouseNameVariable = "$($rootNameValue)sqlDWName"
$analysisServicesServerNameVariable = "$($rootNameValue)AnalysisServicesServerName"
$analysisServicesServerSKUVariable = "$($rootNameValue)AnalysisServicesServerSKU"
$genericActiveDirectoryAdminVariable = "$($rootNameValue)GenericActiveDirectoryAdmin"

$resourceGroupName = Get-AutomationVariable -Name $resourceGroupNameVariable
$location = Get-AutomationVariable -Name $locationVariable	
$subscriptionID = Get-AutomationVariable -Name $subscriptionIDVariable
$storageAccountName = Get-AutomationVariable -Name $storageAccountNameVariable
$storageAccountType = Get-AutomationVariable -Name $storageAccountTypeVariable
$clusterStorageContainer = Get-AutomationVariable -Name $clusterStorageContainerVariable
$rawFilesStorageContainer = Get-AutomationVariable -Name $rawFilesStorageContainerVariable
$sqlServerName = Get-AutomationVariable -Name $sqlServerNameVariable
$sqlServerVersion = Get-AutomationVariable -Name $sqlServerVersionVariable
$sqlAdminCredentials = Get-AutomationPSCredential -Name $sqlAdminCredentialsVariable
$sqlServerIPFirewallRuleName = Get-AutomationVariable -Name $sqlServerIPFirewallRuleNameVariable
$sqlServerIPFirewallRuleStartIP = Get-AutomationVariable -Name $sqlServerIPFirewallRuleStartIPVariable
$sqlServerIPFirewallRuleEndIP = Get-AutomationVariable -Name $sqlServerIPFirewallRuleEndIPVariable
$hiveMetastoreDBName = Get-AutomationVariable -Name $hiveMetastoreDBNameVariable
$hiveMetastoreDBEdition = Get-AutomationVariable -Name $hiveMetastoreDBEditionVariable
$hiveMetastoreDBServiceObjective = Get-AutomationVariable -Name $hiveMetastoreDBServiceObjectiveVariable
$warehouseServiceObjective = Get-AutomationVariable -Name $warehouseServiceObjectiveVariable
$warehouseName = Get-AutomationVariable -Name $warehouseNameVariable
$analysisServicesServerName = Get-AutomationVariable -Name $analysisServicesServerNameVariable
$analysisServicesServerSKU = Get-AutomationVariable -Name $analysisServicesServerSKUVariable
$genericActiveDirectoryAdmin = Get-AutomationVariable -Name $genericActiveDirectoryAdminVariable


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

"Calling NewResourceGroup Runbook..."
.\ChildNewResourceGroup.ps1 `
    -Location $location `
    -SubscriptionId $subscriptionID `
    -ResourceGroupName $resourceGroupName

"Calling NewStorageAccount Runbook..."
.\ChildNewStorageAccount.ps1 `
		-Location $location `
		-StorageAccountName $storageAccountName `
		-SubscriptionId $subscriptionID `
		-ResourceGroupName $resourceGroupName `
		-StorageAccountType $storageAccountType

"Calling NewStorageContainer Runbook for Cluster Storage Container..."
.\ChildNewStorageContainer.ps1 `
    -StorageAccountName $storageAccountName `
    -SubscriptionId $subscriptionID `
    -ResourceGroupName $resourceGroupName `
    -ContainerName $clusterStorageContainer

"Calling NewStorageContainer Runbook for Raw Files Storage Container..."
.\ChildNewStorageContainer.ps1 `
    -StorageAccountName $storageAccountName `
    -SubscriptionId $subscriptionID `
    -ResourceGroupName $resourceGroupName `
    -ContainerName $rawFilesStorageContainer

<#
"Calling NewStorageContainer Runbook for Misc Files Storage Container..."
.\ChildNewStorageContainer.ps1 `
    -StorageAccountName $storageAccountName `
    -SubscriptionId $subscriptionID `
    -ResourceGroupName $resourceGroupName `
    -ContainerName $miscFilesContainerName
#>

"Calling NewAzureSQLDatabaseServer Runbook..."
.\ChildNewAzureSQLDatabaseServer.ps1 `
    -Location $location `
    -SubscriptionId $subscriptionID `
    -ResourceGroupName $resourceGroupName `
    -ServerName $sqlServerName `
    -serverVersion $sqlServerVersion `
    -sqlAdminstratorCredentials $sqlAdminCredentials

"Calling NewAzureSQLDBServerFirewallRuleAllowAzureIPs Runbook..."
.\ChildNewAzureSQLDBServerFirewallRuleAllowAzureIPs.ps1 `
    -SubscriptionId $subscriptionID `
    -ResourceGroupName $resourceGroupName `
    -ServerName $sqlServerName 

"Calling NewAzureSQLDBServerFirewallRuleForIPRange Runbook..."
.\ChildNewAzureSQLDBServerFirewallRuleForIPRange.ps1 `
    -SubscriptionId $subscriptionID `
    -ResourceGroupName $resourceGroupName `
    -ServerName $sqlServerName `
    -EndIPAddress $sqlServerIPFirewallRuleEndIP `
    -StartIPAddress $sqlServerIPFirewallRuleStartIP `
    -FirewallRuleName $sqlServerIPFirewallRuleName

"Calling NewAzureSQLDatabase Runbook to create Hive Metastore DB..."
.\ChildNewAzureSQLDatabase.ps1 `
    -SubscriptionId $subscriptionID `
    -ResourceGroupName $resourceGroupName `
    -DatabaseName $hiveMetastoreDBName `
    -ServerName $sqlServerName `
    -DatabaseEdition $hiveMetastoreDBEdition `
    -databaseRequestedServiceObjective $hiveMetastoreDBServiceObjective

"Calling NewAzureSQLDataWarehouse Runbook to create SQL Data Warehouse..."
.\ChildNewSQLDataWarehouse.ps1 `
    -SubscriptionId $subscriptionID `
    -ResourceGroupName $resourceGroupName `
    -WarehouseName $warehouseName `
    -ServerName $sqlServerName `
    -warehouseRequestedServiceObjective $warehouseServiceObjective

"Calling NewAzureAnalysisServicesServer Runbook to create Azure Analysis Services Server..."
.\ChildNewAzureAnalysisServicesServer.ps1 `
    -SubscriptionId $subscriptionID `
    -ResourceGroupName $resourceGroupName `
    -location $location `
    -analysisServicesServerName $analysisServicesServerName `
    -analysisServicesServerSKU $analysisServicesServerSKU `
    -analysisServicesServerAdmin $genericActiveDirectoryAdmin

$scriptEndTime = (Get-Date)

Write-Output "Script End Time: $scriptEndTime"

$scriptExecutionDuration = New-TimeSpan -Start $scriptStartTime -End $scriptEndTime

$scriptExecutionDurationHours = $scriptExecutionDuration.Hours
$scriptExecutionDurationMinutes = $scriptExecutionDuration.Minutes
$scriptExecutionDurationSeconds = $scriptExecutionDuration.Seconds

Write-Output "Total script execution duration: $scriptExecutionDurationHours : $scriptExecutionDurationMinutes : $scriptExecutionDurationSeconds"