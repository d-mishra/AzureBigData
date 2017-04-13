#*************************************************************************
# MADATORY VARIABLE ENTRY
#*************************************************************************

<# rootName value will be prepended to many other values. 
Please make sure this value only includes lower case letters and numbers.
Value should be kept as short as possible while still conveying meaning #>
$rootNameValue = ""

# Location where the solution files are stored
$rootSourceFileLocation = ""

# Subscription ID for the Azure Subscription that will house the solution
$azureSubscriptionIDValue = ""

# Name of the Azure Automation account that will be used for this solution
$automationAccountName = ""

# Name of the resource group to which the Azure Automation account belongs
$automationResourceGroup = ""

# Administrator(s) of Azure Analysis Services instance - Example: bigbird@microsoft.com
$genericActiveDirectoryAdminValue = "" 

#*************************************************************************
# END MADATORY VARIABLE ENTRY 
#*************************************************************************

<#

This script will remove all the following Azure Automation components created for the solution:
- Variable Assets
- Credentials Assets
- Rubooks (both Parent and Child)

NOTE: It DOES NOT remove the Azure components created/managed by the affected Azure Automation Components.

#>


Write-Host "Selecting Azure Subscription..."
Select-AzureRmSubscription -Subscriptionid $azureSubscriptionIDValue

$variableAssets = 
(Get-AzureRmAutomationVariable `
    -AutomationAccountName $automationAccountName `
    -ResourceGroupName $automationResourceGroup `
    -ErrorAction SilentlyContinue).Name -like "$rootNameValue*"

$credentialAssets = 
(Get-AzureRmAutomationCredential `
    -AutomationAccountName $automationAccountName `
    -ResourceGroupName $automationResourceGroup `
    -ErrorAction SilentlyContinue).Name -like "$rootNameValue*"

$runbooks = 
(Get-AzureRmAutomationRunbook `
    -AutomationAccountName $automationAccountName `
    -ResourceGroupName $automationResourceGroup `
    -ErrorAction SilentlyContinue).Name -like "$rootNameValue*"

If (!($variableAssets))
{
    Write-Host "No variable assets found. `r`n"
}
else
{
    foreach ($variableAsset in $variableAssets)
    {
    
        "Removing variable asset $variableAsset..."
    
        try{
            Remove-AzureRmAutomationVariable `
            -AutomationAccountName $automationAccountName `
            -ResourceGroupName $automationResourceGroup `
            -Name $variableAsset `
            -ErrorAction Stop

            "Variable asset $variableAsset removed. `r`n"
        }
        catch
        {
            Write-Error -Message $_.Exception
            throw $_.Exception
        }
    }
}

If (!($credentialAssets))
{
    Write-Host "No credential assets found. `r`n"
}
else
{
    foreach ($credentialAsset in $credentialAssets)
    {
    
        "Removing credential asset $credentialAsset..."
    
        try{
            Remove-AzureRmAutomationcredential `
            -AutomationAccountName $automationAccountName `
            -ResourceGroupName $automationResourceGroup `
            -Name $credentialAsset

            "Credential asset $credentialAsset removed. `r`n"
        }
        catch
        {
            Write-Error -Message $_.Exception
            throw $_.Exception
        }
    }
}

If (!($credentialAssets))
{
    Write-Host "No credential assets found. `r`n"
}
else
{
    foreach ($runbook in $runbooks)
    {
    
        "Removing runbook $runbook..."
    
        try{
        Remove-AzureRmAutomationRunbook `
        -AutomationAccountName $automationAccountName `
        -ResourceGroupName $automationResourceGroup `
        -Name $runbook `
        -Force

        "Runbook $runbook removed. `r`n"
        }
        catch
        {
            Write-Error -Message $_.Exception
            throw $_.Exception
        }
    }
}

