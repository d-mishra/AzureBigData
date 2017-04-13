<#

.DESCRIPTION
	Resumes SQL Data Warehouse and Analysis Services Server

.NOTES
	Created by Mark Vaillancourt, Microsoft, 2017-01-12

#>

$scriptStartTime = (Get-Date)

Write-Output "Script Start Time: $scriptStartTime"

$rootNameValue ="Solution Root Name Value Placeholder"

# Resolve Asset names based on pocRootNameValue

$subscriptionIDVariable = "$($rootNameValue)AzureSubscriptionID"
$resourceGroupNameVariable = "$($rootNameValue)ResourceGroupName"
$sqlServerNameVariable = "$($rootNameValue)SQLServerName"
$warehouseNameVariable = "$($rootNameValue)sqlDWName"
$analysisServicesServerNameVariable = "$($rootNameValue)AnalysisServicesServerName"


$subscriptionID = Get-AutomationVariable -Name $subscriptionIDVariable
$resourceGroupName = Get-AutomationVariable -Name $resourceGroupNameVariable
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