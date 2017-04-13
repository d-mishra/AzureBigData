
<#

.DESCRIPTION
    Creates a new Azure Analysis Services Server

.NOTES
    Created by Mark Vaillancourt, Microsoft, 2017-01-14

.PARAMETER

    $resourceGroupName
        Name of the Resource Group to which the server
            
    $subscriptionID
        The Subscription ID of the Azure Subscription to which the server will belong

    $location
        Location for the server
    
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
        $location
    , [Parameter(Mandatory=$True)] `
        [string] `
        $analysisServicesServerName 	
    , [Parameter(Mandatory=$True)] `
        [string] `
        $analysisServicesServerSKU  	
    , [Parameter(Mandatory=$True)] `
        [string] `
        $analysisServicesServerAdmin 
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

# Create Azure Analysis Services server if it does not exist
Write-Output "Creating Azure Analysis Services server $analysisServicesServerName ..."

try{
    If(!(Get-AzureRmAnalysisServicesServer `
            -Name $analysisServicesServerName  `
            -ResourceGroupName $resourceGroupName `
            -ErrorAction SilentlyContinue))
    {
        New-AzureRmAnalysisServicesServer `
            -Name $analysisServicesServerName `
            -ResourceGroupName $resourceGroupName `
            -Location $location `
            -Sku $analysisServicesServerSKU `
            -Administrator $analysisServicesServerAdmin `
            -ErrorAction Stop

        Write-Output "Azure Analysis Services server $analysisServicesServerName created successfully."

    }
    Else 
    {
        Write-Output "Azure Analysis Services server $analysisServicesServerName already exists."
    }
}
catch
{
    Write-Error -Message $_.Exception
    throw $_.Exception
}
