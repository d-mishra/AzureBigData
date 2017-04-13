$scriptStartTime = (Get-Date)

Write-Host "Script Start Time: $scriptStartTime"


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

#*************************************************************************
# OPTIONAL VARIABLE ENTRY
#*************************************************************************

# Name of the Azure Region into which the Cluster solution and associated resources will be deployed
# NOTE: This does NOT need to be the same region in which the Azure Automation account exists
$locationNameValue = "South Central US"

# Type of storage account to be created. Default is Standard Locally Redundant Storage
$storageAccountTypeValue = "Standard_LRS"

# Edition of the Azure SQL Database that will serve as the Hive Metastore for the HDInsight Cluster
$hiveMetastoreDBEditionNameValue = "Basic"

# Service Objective of the Azure SQL Database that will serve as the Hive Metastore for the HDInsight Cluster
$hiveMetastoreDBRequestedServiceObjectiveNameValue = "Basic"

# Azure SQL DB Server Version for Hive Metastore and Reporting database
$sqlServerVersionValue = "12.0"

# Ip Range Firewall Rules Start and End IP 
# NOTE: The values used here are not recommended for Production use
$sqlServerFirewallRuleStartIPValue = "0.0.0.0"
$sqlServerFirewallRuleEndIPValue = "255.255.255.255"

# Edition of the Azure SQL Database that will tables that must be available when cluster is not
$sqlDWEditionNameValue = "Basic"

# Service Objective for SQL Data Warehouse
$sqlDWRequestedServiceObjectiveNameValue = "DW100"

# Version for HDInsight Hadoop Cluster
$clusterVersionValue = "3.5"

# The number of data nodes (VMs) for the clusters
$clusterWorkerNodeCountValue = 1

# Size of the Head Node VMs for the cluster
$clusterHeadNodeSizeValue = "Standard_A3"

# Size of the Worker Node VM(s) for the cluster
$clusterWorkerNodeSizeValue = "Standard_A3"

# SKU for Azure Analysis Services Server
$analysisServicesServerSKUValue = "D1"

#*************************************************************************
# END OPTIONAL VARIABLE ENTRY
#*************************************************************************

#*************************************************************************
# POWERSHELL DERIVED VARIABLES
#*************************************************************************

# Password must be at least 
# 10 characters long and must contain at least one number, uppercase letter, lowercase letter and special character with 
# no spaces and should not contain the username as part of it# This password is used for all 3 credentials for this solution. # This is not recommended for a production deployment.$credentialPassword = Read-Host -Prompt "Enter Credential Password to use for Admin Accounts" -AsSecureString

# subfolder where Runbook files are stored
$runbookPowerShellScriptSourceLocation = "$rootSourceFileLocation\Runbooks"

# subfolder where raw files are stored
$rawFileSourceLocation = "$rootSourceFileLocation\Raw Files"

$rootName = "$($rootNameValue)RootName"
$azureSubscriptionID = "$($rootNameValue)AzureSubscriptionID"
$resourceGroupName = "$($rootNameValue)ResourceGroupName"
$resourceGroupNameValue = "$($rootNameValue)rg"
$locationName = "$($rootNameValue)LocationName"
$storageAccountName = "$($rootNameValue)StorageAccountName"
$storageAccountNameValue = "$($rootNameValue)st"
$storageAccountType = "$($rootNameValue)StorageAccountType"
$clusterStorageContainerName = "$($rootNameValue)ClusterStorageContainerName"
$clusterStorageContainerNameValue = "$($rootNameValue)hdp"
$rawFileContainerName = "$($rootNameValue)RawFileContainerName"
$rawFileContainerNameValue = "$($rootNameValue)rawfiles"


$hcatDBName = "$($rootNameValue)HCatalogDBName"
$hcatDBNameValue = "$($rootNameValue)hcat"

$hiveScriptExecutionCompleted = "$($rootNameValue)HiveScriptExecutionCompleted"
$hiveScriptExecutionCompletedValue = "N"

$tsqlScriptExecutionCompleted = "$($rootNameValue)TSQLScriptExecutionCompleted"
$tsqlScriptExecutionCompletedValue = "N"

$sqlServerName = "$($rootNameValue)SQLServerName"
$sqlServerNameValue = "$($rootNameValue)dbserver"
$sqlServerVersion = "$($rootNameValue)SQLServerVersion"

$miscFilesContainerName = "$($rootNameValue)MiscFilesContainer"
$miscFilesContainerNameValue = "$($rootNameValue)miscfiles"

$sqlServerUserName = "$($rootNameValue)sqluser"
$clusterHTTPUsername = "$($rootNameValue)hdpuser"
$clusterSSHUsername = "$($rootNameValue)sshuser"

$sqlServerFirewallRuleIPName = "$($rootNameValue)SQLServerIPFirewallRuleName"
$sqlServerFirewallRuleIPNameValue = "$($sqlServerNameValue)ipfirewallrule"$sqlServerFirewallRuleStartIPName = "$($rootNameValue)SQLServerIPFirewallRuleStartIP"$sqlServerFirewallRuleEndIPName = "$($rootNameValue)SQLServerIPFirewallRuleEndIP"
$hiveMetastoreDBName = "$($rootNameValue)HiveMetastoreDBName"
$hiveMetastoreDBNameValue = "$($rootNameValue)hivedb"$hiveMetastoreDBEditionName = "$($rootNameValue)HiveMetastoreDBEditionName"
$hiveMetastoreDBRequestedServiceObjectiveName = "$($rootNameValue)HiveMetastoreDBRequestedServiceObjectiveName"
$sqlServerCredential = "$($rootNameValue)sqluser"$sqlServerCredentialValue = New-Object System.Management.Automation.PSCredential($sqlServerUserName, $credentialPassword)
$clusterName = "$($rootNameValue)ClusterName"
$clusterNameValue = "$($rootNameValue)hdp"
$clusterWorkerNodeCount = "$($rootNameValue)ClusterWorkerNodeCount"
$clusterHeadNodeSize = "$($rootNameValue)ClusterHeadNodeSize"
$clusterWorkerNodeSize = "$($rootNameValue)ClusterWorkerNodeSize"
$clusterHTTPCredential = "$($rootNameValue)hdpuser"$clusterHTTPCredentialValue = New-Object System.Management.Automation.PSCredential($clusterHTTPUsername, $credentialPassword)
$clusterSSHCredential = "$($rootNameValue)sshuser"$clusterSSHCredentialValue = New-Object System.Management.Automation.PSCredential($clusterSSHUsername, $credentialPassword)
$clusterVersionName = "$($rootNameValue)ClusterVersion"
$sqlDWName = "$($rootNameValue)sqlDWName"
$sqlDWNameValue = "$($rootNameValue)dw"$sqlDWEditionName = "$($rootNameValue)sqlDWEditionName"
$sqlDWRequestedServiceObjectiveName = "$($rootNameValue)sqlDWRequestedServiceObjectiveName"
$analysisServicesServerName = "$($rootNameValue)AnalysisServicesServerName"
$analysisServicesServerNameValue = "$($rootNameValue)as"
$analysisServicesServerSKU = "$($rootNameValue)AnalysisServicesServerSKU"

$analysisServicesCredentialName = "$($rootNameValue)AnalysisServicesAdminCredential"

# Enter the domain password for the account specified as the genericActiveDirectoryAdminValue
# This account will be used for connecting to the Analysis Services server for deployment and processing of the model
#$analysisServicesCredentialPassword = Read-Host -Prompt "Enter Password for $genericActiveDirectoryAdminValue" -AsSecureString

#$analysisServicesCredentialValue = New-Object System.Management.Automation.PSCredential($genericActiveDirectoryAdminValue, $analysisServicesCredentialPassword)



$genericActiveDirectoryAdmin = "$($rootNameValue)GenericActiveDirectoryAdmin"

$hiveQueryScript = "$($rootNameValue)HiveQueryScript"
$hiveQueryScriptValue = 
@'
set hive.execution.engine=tez;

CREATE EXTERNAL TABLE IF NOT EXISTS Bar_RAW
(
	  BarID STRING	
	, BarNumber STRING
	, BarSize STRING	
	, BarFlavor STRING	
	, BarCost STRING	
	, BarSalePrice STRING	
)
ROW FORMAT DELIMITED
        FIELDS TERMINATED BY '|'
STORED AS TEXTFILE
LOCATION '/user/hive/warehouse/Bar/Bar_RAW'
TBLPROPERTIES("skip.header.line.count"="1"); 

LOAD DATA INPATH 'wasbs:///data/Bar/' INTO TABLE Bar_RAW;

CREATE EXTERNAL TABLE IF NOT EXISTS Bar
(
	  BarID STRING	
	, BarNumber STRING
	, BarSize STRING	
	, BarFlavor STRING	
	, BarCost DECIMAL(4,2)	
	, BarSalePrice DECIMAL(4,2)	
)
STORED AS ORC
LOCATION '/user/hive/warehouse/Bar';

INSERT OVERWRITE TABLE Bar
SELECT 
	  BarID 	
	, BarNumber 
	, BarSize 	
	, BarFlavor 	
	, CAST(BarCost AS DECIMAL(4,2))
	, CAST(BarSalePrice AS DECIMAL(4,2))	
FROM Bar_RAW;

CREATE EXTERNAL TABLE IF NOT EXISTS Sales_RAW
(
	  SalesRecordID STRING	
	, StudentID STRING
	, BarID STRING	
	, SaleDate STRING	
	, QuantitySold INT			
)
ROW FORMAT DELIMITED
        FIELDS TERMINATED BY '|'
STORED AS TEXTFILE
LOCATION '/user/hive/warehouse/Sales/Sales_RAW'
TBLPROPERTIES("skip.header.line.count"="1");

LOAD DATA INPATH 'wasbs:///data/Sales/' INTO TABLE Sales_RAW;

CREATE EXTERNAL TABLE IF NOT EXISTS Sales
(
	  SalesRecordID STRING	
	, StudentID STRING
	, BarID STRING	
	, SaleDate STRING	
	, QuantitySold INT
)
STORED AS ORC
LOCATION '/user/hive/warehouse/Sales';

INSERT OVERWRITE TABLE Sales
SELECT 
	  SalesRecordID 	
	, StudentID 
	, BarID 	
	, SaleDate 	
	, QuantitySold 	
FROM Sales_RAW;
'@

#***************************************************************************************************
# VARIABLE ASSETS 
#***************************************************************************************************

Write-Host "Selecting Azure Subscription..."
Select-AzureRmSubscription -Subscriptionid $azureSubscriptionIDValue

# Create function to create variable assets
function CreateVariableAsset
{

    param
    (
      [string] $variableName
    , [string] $variableValue
    )

    Write-Host "Creating Variable Asset $variableName..."

    try{
        If(!(Get-AzureRmAutomationVariable `
            -AutomationAccountName $automationAccountName `
            -ResourceGroupName $automationResourceGroup `
            -Name $variableName `
            -ErrorAction SilentlyContinue))   
        {
        New-AzureRmAutomationVariable `
            -AutomationAccountName $automationAccountName `
            -ResourceGroupName $automationResourceGroup `
            -Name $variableName `
            -Value $variableValue `
            -Encrypted $false `
            -ErrorAction Stop
    
        Write-Host "$variableName created successfully. `r`n"

        }
        Else        {            Write-Host "Variable Asset $variableName already exists. `r`n"        }
    }
    catch
    {
        Write-Error -Message $_.Exception
        throw $_.Exception
    }

}

# Call function to create variable assets
CreateVariableAsset -variableName $rootName -variableValue $rootNameValue
CreateVariableAsset -variableName $azureSubscriptionID -variableValue $azureSubscriptionIDValue
CreateVariableAsset -variableName $resourceGroupName -variableValue $resourceGroupNameValue
CreateVariableAsset -variableName $locationName -variableValue $locationNameValue
CreateVariableAsset -variableName $storageAccountName -variableValue $storageAccountNameValue
CreateVariableAsset -variableName $storageAccountType -variableValue $storageAccountTypeValue
CreateVariableAsset -variableName $clusterStorageContainerName -variableValue $clusterStorageContainerNameValue
CreateVariableAsset -variableName $rawFileContainerName -variableValue $rawFileContainerNameValue
CreateVariableAsset -variableName $miscFilesContainerName -variableValue $miscFilesContainerNameValueCreateVariableAsset -variableName $hcatDBName -variableValue $hcatDBNameValueCreateVariableAsset -variableName $sqlServerName -variableValue $sqlServerNameValueCreateVariableAsset -variableName $sqlServerVersion -variableValue $sqlServerVersionValueCreateVariableAsset -variableName $sqlServerFirewallRuleIPName -variableValue $sqlServerFirewallRuleIPNameValue CreateVariableAsset -variableName $sqlServerFirewallRuleStartIPName -variableValue $sqlServerFirewallRuleStartIPValue CreateVariableAsset -variableName $sqlServerFirewallRuleEndIPName -variableValue $sqlServerFirewallRuleEndIPValue CreateVariableAsset -variableName $hiveMetastoreDBName -variableValue $hiveMetastoreDBNameValueCreateVariableAsset -variableName $hiveMetastoreDBEditionName -variableValue $hiveMetastoreDBEditionNameValueCreateVariableAsset -variableName $hiveMetastoreDBRequestedServiceObjectiveName -variableValue $hiveMetastoreDBRequestedServiceObjectiveNameValueCreateVariableAsset -variableName $sqlDWName -variableValue $sqlDWNameValueCreateVariableAsset -variableName $sqlDWRequestedServiceObjectiveName -variableValue $sqlDWRequestedServiceObjectiveNameValueCreateVariableAsset -variableName $clusterName -variableValue $clusterNameValueCreateVariableAsset -variableName $clusterWorkerNodeCount -variableValue $clusterWorkerNodeCountValueCreateVariableAsset -variableName $clusterHeadNodeSize -variableValue $clusterHeadNodeSizeValueCreateVariableAsset -variableName $clusterWorkerNodeSize -variableValue $clusterWorkerNodeSizeValueCreateVariableAsset -variableName $clusterVersionName -variableValue $clusterVersionValueCreateVariableAsset -variableName $analysisServicesServerName -variableValue $analysisServicesServerNameValueCreateVariableAsset -variableName $analysisServicesServerSKU -variableValue $analysisServicesServerSKUValueCreateVariableAsset -variableName $genericActiveDirectoryAdmin -variableValue $genericActiveDirectoryAdminValueCreateVariableAsset -variableName $hiveScriptExecutionCompleted -variableValue $hiveScriptExecutionCompletedValueCreateVariableAsset -variableName $hiveQueryScript -variableValue $hiveQueryScriptValue
CreateVariableAsset -variableName $tsqlScriptExecutionCompleted -variableValue $tsqlScriptExecutionCompletedValue



#***************************************************************************************************
# CREDENTIAL ASSETS 
#***************************************************************************************************
# Create function to create credential assets
function CreateCredentialAsset
{

    param
    (
      [string] $credentialName
    , [PSCredential] $credentialValue
    )

    Write-Host "Creating Credential Asset $credentialName..."

    try{
        If(!(Get-AzureRmAutomationCredential `
                -AutomationAccountName $automationAccountName `
                -ResourceGroupName $automationResourceGroup `
                -Name $credentialName `
                -ErrorAction SilentlyContinue))   
        {
        New-AzureRmAutomationCredential `
            -AutomationAccountName $automationAccountName `
            -ResourceGroupName $automationResourceGroup `
            -Name $credentialName `
            -Value $credentialValue `
            -ErrorAction Stop
    
        Write-Host "$credentialName created successfully. `r`n"

        }
        Else        {            Write-Host "Credential Asset $credentialName already exists. `r`n"        }
    }
    catch
    {
        Write-Error -Message $_.Exception
        throw $_.Exception
    }

}# Call function to create credential assets
CreateCredentialAsset -credentialName $sqlServerCredential -credentialValue $sqlServerCredentialValueCreateCredentialAsset -credentialName $clusterHTTPCredential -credentialValue $clusterHTTPCredentialValueCreateCredentialAsset -credentialName $clusterSSHCredential -credentialValue $clusterSSHCredentialValue#CreateCredentialAsset -credentialName $analysisServicesCredentialName -credentialValue $analysisServicesCredentialValue#***************************************************************************************************
# IMPORT CHILD RUNBOOKS
#***************************************************************************************************$childRunbookPowerShellScriptSourceLocation = "$runbookPowerShellScriptSourceLocation\Child"$parentRunbookPowerShellScriptSourceLocation = "$runbookPowerShellScriptSourceLocation\Parent"$modifiedRunbookPowerShellScriptLocation = "$runbookPowerShellScriptSourceLocation\Parent Modified"$childRunbooks = (Get-ChildItem $childRunbookPowerShellScriptSourceLocation).Basename$parentRunbooks = (Get-ChildItem $parentRunbookPowerShellScriptSourceLocation).BasenameWrite-Host "Importing child runbooks from $childRunbookPowerShellScriptSourceLocation..."foreach ($childRunbook in $childRunbooks){    $childRunbookName = $rootNameValue + $childRunbook    $childRunbookPath = "$childRunbookPowerShellScriptSourceLocation\$childRunbook.ps1"    Write-Host "Importing Child Runbook $childRunbookName..."    try{        If(!(Get-AzureRmAutomationRunbook `
            -AutomationAccountName $automationAccountName `
            -ResourceGroupName $automationResourceGroup `
            -Name $childRunbookName `
            -ErrorAction SilentlyContinue))   
        {
        Import-AzureRmAutomationRunbook `
            -AutomationAccountName $automationAccountName `
            -ResourceGroupName $automationResourceGroup `
            -Name $childRunbookName `
            -Type PowerShell `
            -Path $childRunbookPath `
            -ErrorAction Stop
    
        Write-Host "Child Runbook $childRunbookName imported successfully. `r`n"
        
        }
        Else        {            Write-Host "Child Runbook $childRunbookName already exists. `r`n"        }
    }
    catch
    {
        Write-Error -Message $_.Exception
        throw $_.Exception
    }

    Write-Host "Publishing PowerShell Runbook $childRunbookName..."        $childRunbookState = (Get-AzureRmAutomationRunbook `
            -AutomationAccountName $automationAccountName `
            -ResourceGroupName $automationResourceGroup `
            -Name $childRunbookName `
            -ErrorAction SilentlyContinue).State        try{        If($childRunbookState -ne "Published")   
        {        Publish-AzureRmAutomationRunbook `            -AutomationAccountName $automationAccountName `
            -ResourceGroupName $automationResourceGroup  `
            -Name $childRunbookName `            -ErrorAction Stop         Write-Host "Child Runbook $childRunbookName published. `r`n"
        
        }
        Else        {            Write-Host "Child Runbook $childRunbookName already published. `r`n"        }    }
    catch
    {
        Write-Error -Message $_.Exception
        throw $_.Exception
    }}#***************************************************************************************************
# IMPORT MODIFIED PARENT RUNBOOKS
#***************************************************************************************************Write-Host "Importing parent runbooks from $parentRunbookPowerShellScriptSourceLocation..."foreach ($parentRunbook in $parentRunbooks){    $parentRunbookName = $rootNameValue + $parentRunbook    $parentRunbookPath = "$parentRunbookPowerShellScriptSourceLocation\$parentRunbook.ps1"    $modifiedRunbookPath = "$modifiedRunbookPowerShellScriptLocation\$parentRunbookName.ps1"    Write-Host "Removing Modified Runbook file $parentRunbookName if it exists..."        try{        If([System.IO.File]::Exists($modifiedRunbookPath))        {            Remove-Item $modifiedRunbookPath `            -ErrorAction Stop            Write-Host "Modified Runbook $parentRunbookName removed."        }        Else        {            Write-Host "Modified Runbook file $parentRunbookName does not exist. `r`n"        }    }
    catch
    {
        Write-Error -Message $_.Exception
        throw $_.Exception
    }    Write-Host "Creating Modified Runbook file $parentRunbookName..."    Write-Host "Replacing placeholder value with $rootNameValue in Modified Runbook file..."        try{        (Get-Content $parentRunbookPath) `            | ForEach-Object { $_.replace('.\',".\$rootNameValue").replace('Solution Root Name Value Placeholder', $rootNameValue)} `            | Set-Content $modifiedRunbookPath `            -ErrorAction Stop        "Modified Runbook file $parentRunbookName created. `r`n"    }    catch
    {
        Write-Error -Message $_.Exception
        throw $_.Exception
    }    Write-Host "Importing Parent Runbook $parentRunbookName from Modified Runbook file..."    try{        If(!(Get-AzureRmAutomationRunbook `
            -AutomationAccountName $automationAccountName `
            -ResourceGroupName $automationResourceGroup `
            -Name $parentRunbookName `
            -ErrorAction SilentlyContinue))   
        {
        Import-AzureRmAutomationRunbook `
            -AutomationAccountName $automationAccountName `
            -ResourceGroupName $automationResourceGroup `
            -Name $parentRunbookName `
            -Type PowerShell `
            -Path $modifiedRunbookPath `
            -ErrorAction Stop
        }        Else        {            Write-Host "Parent Runbook file $parentRunbookName already exists. `r`n"        }
    }
    catch
    {
        Write-Error -Message $_.Exception
        throw $_.Exception
    }

    Write-Host "Publishing PowerShell Runbook $parentRunbookName..."        $parentRunbookState = (Get-AzureRmAutomationRunbook `
            -AutomationAccountName $automationAccountName `
            -ResourceGroupName $automationResourceGroup `
            -Name $parentRunbookName `
            -ErrorAction SilentlyContinue).State        try{        If($parentRunbookState -ne "Published")  
        {        Publish-AzureRmAutomationRunbook `            -AutomationAccountName $automationAccountName `
            -ResourceGroupName $automationResourceGroup  `
            -Name $parentRunbookName `            -ErrorAction Stop         "Parent Runbook $parentRunbookName published. `r`n"
        
        }
        Else        {            Write-Host "Parent Runbook $parentRunbookName already published. `r`n"        }    }
    catch
    {
        Write-Error -Message $_.Exception
        throw $_.Exception
    }}$scriptEndTime = (Get-Date)

Write-Host "Script End Time: $scriptEndTime"

$scriptExecutionDuration = New-TimeSpan -Start $scriptStartTime -End $scriptEndTime

$scriptExecutionDurationHours = $scriptExecutionDuration.Hours
$scriptExecutionDurationMinutes = $scriptExecutionDuration.Minutes
$scriptExecutionDurationSeconds = $scriptExecutionDuration.Seconds

Write-Host "Total script execution duration: $scriptExecutionDurationHours : $scriptExecutionDurationMinutes : $scriptExecutionDurationSeconds"