

<#

.DESCRIPTION
	Creates a new Resource Group if it does not already exist

.NOTES
	Created by Mark Vaillancourt, Microsoft, 2016-08-03

.PARAMETER

	$resourceGroupName
		Name the Resrouce Group will have
	
	$location
		Azure Region into which the Resource Group should be created

	$subscriptionID
		The Subscription ID of the Azure Subscription into which the Resource Group should be created

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

# Create a resource group if it does not exist
Write-Output "Creating Resource Group $resourceGroupName..."

try{
    If(!(Get-AzureRmResourceGroup `
            -Name $resourceGroupName `
            -Location $location `
            -ErrorAction SilentlyContinue))
    {
        New-AzureRmResourceGroup `
            -Name $resourceGroupName `
            -Location $location `
            -ErrorAction Stop

        Write-Output "Resource Group $resourceGroupName created successfully."

    }
    Else 
    {
        Write-Output "Resource Group $resourceGroupName already exists."
    }
}
catch
{
    Write-Error -Message $_.Exception
    throw $_.Exception
}
