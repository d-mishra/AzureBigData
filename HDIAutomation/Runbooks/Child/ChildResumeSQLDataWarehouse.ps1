
<#

.DESCRIPTION
    Resumes an Azure SQL Data Warehouse

.NOTES
    Created by Mark Vaillancourt, Microsoft, 2017-01-14

.PARAMETER

    $resourceGroupName
        Name of the Resource Group to which the Warehouse belongs
            
    $subscriptionID
        The Subscription ID of the Azure Subscription to which the Warehouse belongs

    $serverName
        Name of the Azure SQL Database Server that contains the Warehouse
        
    $warehouseName
        Name of the Azure SQL Data Warehouse to be Resumed

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

# Resume Azure SQL Data Warehouse

Write-Output "Resuming Azure SQL Data Warehouse $warehouseName..."

try{
    If((Get-AzureRmSqlDatabase `
            -ResourceGroupName $resourceGroupName `
            -ServerName $serverName `
            -DatabaseName $warehouseName  `
            -ErrorAction SilentlyContinue)) 
    {
    
        $DWStatus = (Get-AzureRmSqlDatabase `
            -ResourceGroupName $resourceGroupName `
            -ServerName $serverName `
            -DatabaseName $warehouseName).Status
    
        If($DWStatus -eq "Paused")
        {  
        Resume-AzureRmSqlDatabase `
            -ResourceGroupName $resourceGroupName `
            -ServerName $serverName `
            -DatabaseName $warehouseName `
            -ErrorAction Stop  

        Write-Output "SQL Data Warehouse $warehouseName Resumed successfully."
        }
        Else
        {
            Write-Output "SQL Data Warehouse $warehouseName not Paused."
        }  

    }
    Else
    {
        Write-Output "Azure SQL Data Warehouse $warehouseName does not exist..."
    }
}
catch
{
    Write-Error -Message $_.Exception
    throw $_.Exception
}

