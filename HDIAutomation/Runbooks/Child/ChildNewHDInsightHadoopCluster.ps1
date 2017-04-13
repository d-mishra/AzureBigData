
<#

.DESCRIPTION
    Creates a new HDInsight Cluster if it does not already exist

.NOTES
    Created by Mark Vaillancourt, Microsoft, 2016-08-08

.PARAMETER

    $resourceGroupName
        Name of the Resrouce Group that will house the Cluster

    $storageAccountName
        Name of the Storage Account to use for the Cluster

    $sqlAzureServerName
        Name of the Azure SQL Database Server that will hold the Hive Metastore database
        
    $sqlAzureDatabaseName
        Name of the Azure SQL Database that will serve as the Hive Metastore database
        
    $clusterName
        Name for the HDInsight cluster
    
    $location
        Azure Region into which the Resource Group should be created

    $clusterType
        Type of HDInsight cluster to be created
        
    $clusterVersion
        Version of the HDInsight cluster to be created
        
    $defaultStorageContainerName
        Name of the Default Storage Container for the cluster
        
    $clusterSizeInNodes
        Number of Worker nodes for the cluster
        
    $headNodeSize
        Size of virtual machine to use for the Head Nodes
        
    $workerNodeSize
        Size of virtual machine to use for the Worker Node(s)			
    
    $clusterHTTPCredential
        Credential for the HTTP Administrative user for the cluster
        
    $clusterSSHCredential
        Credential for the SSH Administrative user for the cluster	

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
        $storageAccountName 	
    , [Parameter(Mandatory=$True)] `
        [string] `
        $sqlAzureServerName 			
    , [Parameter(Mandatory=$True)] `
        [string] `
        $sqlAzureDatabaseName 	
    , [Parameter(Mandatory=$True)] `
        [string] `
        $clusterName 
    , [Parameter(Mandatory=$True)] `
        [string] `
        $location 
    , [Parameter(Mandatory=$True)] `
        [string] `
        $clusterType  
    , [Parameter(Mandatory=$True)] `
        [string] `
        $clusterVersion 
    , [Parameter(Mandatory=$True)] `
        [string] `
        $defaultStorageContainerName 
    , [Parameter(Mandatory=$True)] `
        [string] `
        $clusterSizeInNodes 
    , [Parameter(Mandatory=$True)] `
        [string] `
        $headNodeSize 
    , [Parameter(Mandatory=$True)] `
        [string] `
        $workerNodeSize 
    , [Parameter(Mandatory=$True)] `
        [PSCredential] `
        $sqlAzureServerCredential  
    , [Parameter(Mandatory=$True)] `
        [PSCredential] `
        $clusterHTTPCredential
    , [Parameter(Mandatory=$True)] `
        [PSCredential] `
        $clusterSSHCredential
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

# Get Storage Account Key
$storageAccountArray = Get-AzureRmStorageAccountKey -ResourceGroupName $resourceGroupName -Name $storageAccountName

$storageAccountKey = $storageAccountArray.Item(0).Value

# Create HDInsight cluster
     
$config = New-AzureRmHDInsightClusterConfig -ClusterType Hadoop `
    | Add-AzureRmHDInsightMetastore `
        -SqlAzureServerName "$sqlAzureServerName.database.windows.net"  `
        -DatabaseName $sqlAzureDatabaseName `
        -Credential $sqlAzureServerCredential `
        -MetastoreType HiveMetastore `
        | Add-AzureRmHDInsightConfigValues -WebHCat @{'templeton.libjars'='/usr/hdp/${hdp.version}/zookeeper/zookeeper.jar,/usr/hdp/${hdp.version}/hive/lib/hive-common.jar,/usr/hdp/${hdp.version}/hive-hcatalog/share/hcatalog/hive-hcatalog-core.jar,/usr/hdp/${hdp.version}/hive-hcatalog/share/hcatalog/hive-hcatalog-pig-adapter.jar,/usr/hdp/${hdp.version}/hive-hcatalog/share/hcatalog/hive-hcatalog-server-extensions.jar,/usr/hdp/${hdp.version}/hive-hcatalog/share/hcatalog/hive-hcatalog-streaming.jar'}  

Write-Output "Creating HDInsight cluster $clusterName..."

try{
    If(!(Get-AzureRmHDInsightCluster `
            -ResourceGroupName $resourceGroupName `
            -ClusterName $clusterName `
            -ErrorAction SilentlyContinue))
    {

        New-AzureRmHDInsightCluster `
            -Config $config `
            -ResourceGroupName $resourceGroupName `
            -ClusterName $clusterName `
            -ClusterType "Hadoop" `
            -ClusterSizeInNodes $clusterSizeInNodes `
            -HttpCredential $clusterHTTPCredential `
            -Version $clusterVersion `
            -Location $location `
            -DefaultStorageAccountName "$storageAccountName.blob.core.windows.net" `
            -DefaultStorageAccountKey $storageAccountKey `
            -DefaultStorageContainer $defaultStorageContainerName `
            -HeadNodeSize $headNodeSize `
            -WorkerNodeSize $workerNodeSize `
            -OSType "Linux" `
            -SshCredential $clusterSSHCredential `
            -ErrorAction Stop  

        Write-Output "HDInsight Cluster $clusterName created successfully."

    }
    Else 
    {
        Write-Output "HDInsight Cluster $clusterName already exists."
    } 
}
catch
{
    Write-Error -Message $_.Exception
    throw $_.Exception
}

		



