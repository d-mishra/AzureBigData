
<#

.DESCRIPTION
    Creates a new Azure SQL Data Warehouse if it does not already exist

.NOTES
    Created by Mark Vaillancourt, Microsoft, 2017-01-14

.PARAMETER

    $resourceGroupName
        Name of the Resource Group to which the Warehouse will belong
            
    $subscriptionID
        The Subscription ID of the Azure Subscription to which the Warehouse will belong

    $serverName
        Name of the Azure SQL Database Server that will contain the Warehouse
        
    $warehouseName
        Name of the Azure SQL Data Warehouse to be Created
        
    $warehouseRequestedServiceObjective
        Requested Service Objective of the Database to be Created

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
        $serverName 	
    , [Parameter(Mandatory=$True)] `
        [string] `
        $warehouseName  	
    , [Parameter(Mandatory=$True)] `
        [string] `
        $warehouseRequestedServiceObjective 
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

# Create Azure SQL Data Warehouse

Write-Output "Creating SQL Data Warehouse $warehouseName..."

try{
    If(!(Get-AzureRmSqlDatabase `
            -ResourceGroupName $resourceGroupName `
            -ServerName $serverName `
            -DatabaseName $warehouseName  `
            -ErrorAction SilentlyContinue)) 
    {
        New-AzureRmSqlDatabase `
            -ResourceGroupName $resourceGroupName `
            -ServerName $serverName `
            -DatabaseName $warehouseName  `
            -Edition DataWarehouse `
            -RequestedServiceObjectiveName $warehouseRequestedServiceObjective `
            -ErrorAction Stop

        Write-Output "SQL Data Warehouse $warehouseName created successfully."
    }
    Else
    {
        Write-Output "SQL Data Warehouse $warehouseName already exists."
    }
}
catch
{
    Write-Error -Message $_.Exception
    throw $_.Exception
}
