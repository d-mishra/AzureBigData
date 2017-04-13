
<#

.DESCRIPTION
    Executes a hive script against the HDInsight Hadoop cluster

.NOTES
    Created by Mark Vaillancourt, Microsoft, 2017-01-31

.PARAMETER

    $resourceGroupName
        Name of the Resrouce Group that houses the Cluster
       
    $clusterName
        Name of the HDInsight cluster
    
    $subscriptionID
        ID of the Azure subscription

    $hiveQueryString
        hive query language script text			
    
    $clusterHTTPCredential
        Credential for the HTTP Administrative user for the cluster	

#>

param
(
      [Parameter(Mandatory=$True)] `
        [string] `
        $resourceGroupName 
    , [Parameter(Mandatory=$True)] `
        [string] `
        $subscriptionID 
    , [Parameter(Mandatory=$True)] `
        [string] `
        $hiveQueryString 
    , [Parameter(Mandatory=$True)] `
        [string] `
        $clusterName 
    , [Parameter(Mandatory=$True)] `
        [PSCredential] `
        $clusterHTTPCredential
)

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

Write-Output "Selecting Azure Subscription..."
Select-AzureRmSubscription -Subscriptionid $subscriptionID

Write-Output "Executing Hive script against $clusterName..."

try
{
    If((Get-AzureRmHDInsightCluster `
            -ResourceGroupName $resourceGroupName `
            -ClusterName $clusterName `
            -ErrorAction SilentlyContinue))
    {

        $hiveJobDefinition = New-AzureRmHDInsightHiveJobDefinition `
                                -Query $hiveQueryString       
        
        $hiveJob = Start-AzureRmHDInsightJob `
                    -ClusterName $clusterName `
                    -HttpCredential $clusterHTTPCredential `
                    -JobDefinition $hiveJobDefinition `
                    -ErrorAction Stop  
        
        $hiveJobID = $hiveJob.JobID
        
        Wait-AzureRmHDInsightJob `
            -ClusterName $clusterName `
            -HttpCredential $clusterHTTPCredential `
            -JobId $hiveJobID
        
        Get-AzureRmHDInsightJobOutput `
            -ClusterName $clusterName `
            -HttpCredential $clusterHTTPCredential `
            -JobId $hiveJobID                                           

        Write-Output "Hive script executed successfully."

    }
    Else 
    {
        Write-Output "HDInsight Cluster $clusterName does not exist."
    } 
}
catch
{
    Write-Error -Message $_.Exception
    throw $_.Exception
}
		



