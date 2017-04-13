
<#

.DESCRIPTION
    Creates a new Allow Azure IP Firewall Rule if it does not already exist

.NOTES
    Created by Mark Vaillancourt, Microsoft, 2016-08-03

.PARAMETER

    $resourceGroupName
        Name of the Resrouce Group to which the Server belongs
    
    $serverName
        Azure SQL Database Server for which the Firewall Rule should be created

    $subscriptionID
        The Subscription ID of the Azure Subscription to which the Azure SQL Database Server belongs

#>

param
(
        [Parameter(Mandatory=$True)] `
        [string] `
        $resourceGroupName 
    , [Parameter(Mandatory=$True)] `
        [string] `
        $serverName 
    , [Parameter(Mandatory=$True)] `
        [string] `
        $subscriptionID 	
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

# Create Azure SQL Database Server Firewall Rule for Azure IPs

Write-Output "Create Database Server Firewall Rule AllowAllAzureIPs..."

try{
    If(!(Get-AzureRmSqlServerFirewallRule `
            -ResourceGroupName $resourceGroupName `
            -ServerName $serverName `
            -FirewallRuleName "AllowAllAzureIPs" `
            -ErrorAction SilentlyContinue))
    {
        New-AzureRmSqlServerFirewallRule `
            -ResourceGroupName $resourceGroupName `
            -ServerName $serverName `
            -AllowAllAzureIPs `
            -ErrorAction Stop

        Write-Output "Firewall Rule AllowAllAzureIPs created successfully."
    }
    Else
    {
        Write-Output "Database Server Firewall Rule AllowAllAzureIPs already exists."
    }
}
catch
{
    Write-Error -Message $_.Exception
    throw $_.Exception
}
