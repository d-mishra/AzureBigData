
<#

.DESCRIPTION
    Creates a new Azure SQL Database if it does not already exist

.NOTES
    Created by Mark Vaillancourt, Microsoft, 2016-08-08

.PARAMETER

    $resourceGroupName
        Name of the Resource Group to which the Database will belong
            
    $subscriptionID
        The Subscription ID of the Azure Subscription to which the Database will belong

    $serverName
        Name of the Azure SQL Database Server that will contain the database
        
    $databaseName
        Name of the Azure SQL Database to be Created
        
    $databaseEdition
        Edition of the Database to be created 

    $databaseRequestedServiceObjective
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
        $databaseName 	
    , [Parameter(Mandatory=$True)] `
        [string] `
        $databaseEdition 	
    , [Parameter(Mandatory=$True)] `
        [string] `
        $databaseRequestedServiceObjective 
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

# Create Azure SQL Database

Write-Output "Creating Azure SQL Database $databaseName..."

try{
    If(!(Get-AzureRmSqlDatabase `
            -ResourceGroupName $resourceGroupName `
            -ServerName $serverName `
            -DatabaseName $databaseName `
            -ErrorAction SilentlyContinue)) 
    {
        New-AzureRmSqlDatabase `
            -ResourceGroupName $resourceGroupName `
            -ServerName $serverName `
            -DatabaseName $databaseName `
            -Edition $databaseEdition `
            -RequestedServiceObjectiveName $databaseRequestedServiceObjective `
            -ErrorAction Stop

        Write-Output "Azure SQL Database $databaseName created successfully."

    }
    Else
    {
        Write-Output "Azure SQL Database $databaseName already exists."
    }
}
catch
{
    Write-Error -Message $_.Exception
    throw $_.Exception
}
