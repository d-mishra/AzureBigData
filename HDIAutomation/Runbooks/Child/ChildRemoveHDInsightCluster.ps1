
<#

.DESCRIPTION
    Remove an HDInsight Cluster if it exists

.NOTES
    Created by Mark Vaillancourt, Microsoft, 2016-08-08

.PARAMETER

    $resourceGroupName
        Name of the Resrouce Group that will house the Cluster

    $storageAccountName
        Name of the Storage Account to use for the Cluster

    $clusterName
        Name for the HDInsight cluster
    

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
        $clusterName 

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

Write-Output "Removing HDInsight cluster $clusterName..."

try{
    If((Get-AzureRmHDInsightCluster `
            -ResourceGroupName $resourceGroupName `
            -ClusterName $clusterName `
            -ErrorAction SilentlyContinue))
    {

        Remove-AzureRmHDInsightCluster `
            -ResourceGroupName $resourceGroupName `
            -ClusterName $clusterName `
            -ErrorAction Stop 
 
        Write-Output "HDInsight Cluster $clusterName removed successfully."

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
		



