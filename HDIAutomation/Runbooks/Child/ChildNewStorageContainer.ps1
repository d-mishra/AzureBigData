<#

.DESCRIPTION
	Creates a new Container in the specified Storage Account if it does not already exist

.NOTES
	Created by Mark Vaillancourt, Microsoft, 2016-08-03

.PARAMETER

	$resourceGroupName
		Name of the Resrouce Group in which the Storage Account resides

	$subscriptionID
		The Subscription ID of the Azure Subscription in which the Storage Account resides
	
	$storageAccountName
		Name of the Storage Account into which the Container is to be created
	
	$containerName
		Name of the Container to be created

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
        $containerName 	  	
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

$storageAccountArray = Get-AzureRmStorageAccountKey `
                        -ResourceGroupName $resourceGroupName `
                        -Name $storageAccountName

$storageAccountKey = $storageAccountArray[0].Value

$destContext = New-AzureStorageContext `
                        -StorageAccountName $storageAccountName `
                        -StorageAccountKey $storageAccountKey 
    
# Create a Blob storage container if it does not exist

Write-Output "Creating Storage Container $containerName..."

try{
    If(!(Get-AzureStorageContainer `
            -Name $containerName `
            -Context $destContext `
            -ErrorAction SilentlyContinue))
    {
        New-AzureStorageContainer `
            -Name $containerName `
            -Context $destContext `
            -ErrorAction Stop

        Write-Output "Storage Container $containerName created successfully."

    }
    Else 
    {
        Write-Output "Storage Container $containerName already exists."
    }
}
catch
{
    Write-Error -Message $_.Exception
    throw $_.Exception
}
	