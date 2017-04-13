
<#

.DESCRIPTION
	Creates a new Azure SQL Database Server if it does not already exist

.NOTES
	Created by Mark Vaillancourt, Microsoft, 2016-08-03

.PARAMETER

	$resourceGroupName
		Name of the Resource Group that will house the Server
			
	$location
		Azure Region in which the Resource Group resides

	$subscriptionID
		The Subscription ID of the Azure Subscription into which the Server should be created
		
	$serverName
		Name of the Azure SQL Database Server to be Created
		
	$serverVersion
		Azure SQL Database Version of the Server to be Created
		
	$sqlAdministratorCredentials
		Credentials to use for the Administrator Account on the Server 

#>

param
(
      [Parameter(Mandatory=$True)] `
        [string] `
        $resourceGroupName 
    , [Parameter(Mandatory=$True)] `
        [string] `
        $location	
    , [Parameter(Mandatory=$True)] `
        [string] `
        $subscriptionID 
    , [Parameter(Mandatory=$True)] `
        [string] `
        $serverName 	
    , [Parameter(Mandatory=$True)] `
        [string] `
        $serverVersion 	
    , [Parameter(Mandatory=$True)] `
        [PSCredential] `
        $sqlAdminstratorCredentials	
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

# Create Azure SQL Database Server to house the Hive Metastore

Write-Output "Creating Azure SQL Database Server $serverName..."

try{
    If(!(Get-AzureRmSqlServer `
            -ResourceGroupName $resourceGroupName `
            -ServerName $serverName `
            -ErrorAction SilentlyContinue))
    {
        New-AzureRmSqlServer `
            -ResourceGroupName $resourceGroupName `
            -ServerName $serverName `
            -Location $location `
            -ServerVersion $serverVersion `
            -SqlAdministratorCredentials $sqlAdminstratorCredentials `
            -ErrorAction Stop
        
        Write-Output "SQL Database Server $serverName created successfully." 

    } 
    Else
    {
        Write-Output "Azure SQL Database Server $serverName already exists."
    }
}
catch
{
    Write-Error -Message $_.Exception
    throw $_.Exception
}


