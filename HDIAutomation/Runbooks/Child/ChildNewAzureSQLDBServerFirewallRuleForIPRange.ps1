
<#

.DESCRIPTION
    Creates a new IP Range Firewall Rule if it does not already exist

.NOTES
    Created by Mark Vaillancourt, Microsoft, 2016-08-03

.PARAMETER

    $resourceGroupName
        Name of the Resrouce Group to which the Server belongs

    $subscriptionID
        The Subscription ID of the Azure Subscription to which the Server belongs
                
    $serverName
        Azure SQL Database Server for which the Firewall Rule should be created

    $firewallRuleName
        Name to give the Firewall Rule
        
    $startIPAddress
        IP Address at lower end of IP range

    $endIPAddress
        IP Address at higher end of IP range

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
        $firewallRuleName 
    , [Parameter(Mandatory=$True)] `
        [string] `
        $startIPAddress 
    , [Parameter(Mandatory=$True)] `
        [string] `
        $endIPAddress 
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

# Create Azure SQL Database Server Firewall Rule for IP Range

$fullFirewallRuleName = "$($firewallRuleName)_$($startIPAddress)_$($endIPAddress)"

Write-Output "Create Database Server Firewall Rule $fullFirewallRuleName..."

try{
    If(!(Get-AzureRmSqlServerFirewallRule `
            -ResourceGroupName $resourceGroupName `
            -ServerName $serverName `
            -FirewallRuleName $fullFirewallRuleName `
            -ErrorAction SilentlyContinue))
    {
        New-AzureRmSqlServerFirewallRule `
            -ResourceGroupName $resourceGroupName `
            -ServerName $serverName `
            -FirewallRuleName $fullFirewallRuleName `
            -StartIpAddress $startIPAddress `
            -EndIpAddress $endIPAddress `
            -ErrorAction Stop

        Write-Output "Firewall Rule $fullFirewallRuleName created successfully."

    }
    Else
    {
        Write-Output "Database Server Firewall Rule $fullFirewallRuleName already exists."
    }
}
catch
{
    Write-Error -Message $_.Exception
    throw $_.Exception
}
