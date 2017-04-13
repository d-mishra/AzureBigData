<#

.DESCRIPTION
	Execute the Hive script against the HDInsight Hadoop cluster

.NOTES
	Created by Mark Vaillancourt, Microsoft, 2017-01-31

#>

$rootNameValue ="Solution Root Name Value Placeholder"

# Resolve Asset names based on pocRootNameValue

$subscriptionIDVariable = "$($rootNameValue)AzureSubscriptionID"
$resourceGroupNameVariable = "$($rootNameValue)ResourceGroupName"
$clusterNameVariable = "$($rootNameValue)ClusterName"
$hiveQueryScriptVariable = "$($rootNameValue)HiveQueryScript"
$clusterHTTPCredentialVariable = "$($rootNameValue)hdpuser"
$hiveScriptExecutionCompletedVariable = "$($rootNameValue)HiveScriptExecutionCompleted"

$subscriptionID = Get-AutomationVariable -Name $subscriptionIDVariable
$resourceGroupName = Get-AutomationVariable -Name $resourceGroupNameVariable
$clusterName = Get-AutomationVariable -Name $clusterNameVariable
$hiveQueryScript = Get-AutomationVariable -Name $hiveQueryScriptVariable
$clusterHTTPCredential = Get-AutomationPSCredential -Name $clusterHTTPCredentialVariable
$hiveScriptExecutionCompleted = Get-AutomationVariable -Name $hiveScriptExecutionCompletedVariable

$connectionName = "AzureRunAsConnection"
    
try
{
    # Get the connection "AzureRunAsConnection "
    $servicePrincipalConnection=Get-AutomationConnection -Name $connectionName         

    Write-Output "Logging in to Azure..."
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

if($hiveScriptExecutionCompleted -eq "N")
{
    try
    {
        
        Write-Output "Executing Hive script since it has not yet been executed."

        "Calling ChildExecuteHiveQuery Runbook to create and populate Hive tables..."
        .\ChildExecuteHiveQuery.ps1 `
		        -subscriptionId $subscriptionID `
		        -resourceGroupName $resourceGroupName `
		        -clusterName $clusterName `
                -hiveQueryString $hiveQueryScript `
                -clusterHTTPCredential $clusterHTTPCredential
        
        Write-Output "Setting $hiveScriptExecutionCompletedVariable to Y to indicate completion of Hive script."

        Set-AutomationVariable -Name $hiveScriptExecutionCompletedVariable -Value "Y"
    
    }
    catch
    {
        Write-Error -Message $_.Exception
        throw $_.Exception
    }
}
else
{
    Write-Output "Hive exeuction already completed."
}
 

