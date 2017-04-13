
<#

.DESCRIPTION
    Creates a new Azure Analysis Services Server

.NOTES
    Created by Mark Vaillancourt, Microsoft, 2017-01-14

.PARAMETER

    $resourceGroupName
        Name of the Resource Group to which the server belongs
            
    $subscriptionID
        The Subscription ID of the Azure Subscription to which the server belongs
       
    $analysisServicesServerName
        Name of the Azure Analysis Services server to be Resumed


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
        $analysisServicesServerName 	
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

# Resume Azure Analysis Services server if it does not exist
Write-Output "Resuming Azure Analysis Services server $analysisServicesServerName ..."

try{
    If((Get-AzureRmAnalysisServicesServer `
            -Name $analysisServicesServerName  `
            -ResourceGroupName $resourceGroupName `
            -ErrorAction SilentlyContinue))
    {
    
        $ASServerState = (Get-AzureRmAnalysisServicesServer `
            -Name $analysisServicesServerName  `
            -ResourceGroupName $resourceGroupName).ProvisioningState
    
        If($ASServerState -eq "Paused")
        {    
        Resume-AzureRmAnalysisServicesServer `
            -Name $analysisServicesServerName `
            -ResourceGroupName $resourceGroupName `
            -ErrorAction Stop

        Write-Output "Azure Analysis Services server $analysisServicesServerName Resumed successfully."
        }
        Else
        {
            Write-Output "Azure Analysis Services server $analysisServicesServerName not Paused."
        }

    }
    Else 
    {
        Write-Output "Azure Analysis Services server $analysisServicesServerName does not exist."
    }
}
catch
{
    Write-Error -Message $_.Exception
    throw $_.Exception
}
