<#

.DESCRIPTION
	Creates a new Storage Account if it does not already exist

.NOTES
	Created by Mark Vaillancourt, Microsoft, 2016-08-03

.PARAMETER

	$resourceGroupName
		Name of the Resrouce Group to which the Storage Account should belong
	
	$location
		Azure Region into which the Storage Account should be created

	$subscriptionID
		The Subscription ID of the Azure Subscription into which the Storage Account should be created

	$storageAccountName
		Name of the Storage Account to be created
	
	$storageAccountType
		Type of Storage Account to be created

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
        $storageAccountName 
    , [Parameter(Mandatory=$True)] `
        [string] `
        $storageAccountType  	
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

# Create a storage account if it does not exist

Write-Output "Creating Storage Account $storageAccountName..."

try{
    If(!(Get-AzureRmStorageAccount `
            -Name $storageAccountName `
            -ResourceGroupName $resourceGroupName `
            -ErrorAction SilentlyContinue))
    {
        New-AzureRmStorageAccount `
            -Name $storageAccountName `
            -ResourceGroupName $resourceGroupName `
            -Type $storageAccountType `
            -Location $location `
            -EnableEncryptionService Blob `
            -ErrorAction Stop

        Write-Output "Storage Account $storageAccountName created successfully."

    }
    Else 
    {
        Write-Output "Storage Account $storageAccountName already exists."
    }
}
catch
{
    Write-Error -Message $_.Exception
    throw $_.Exception
}


