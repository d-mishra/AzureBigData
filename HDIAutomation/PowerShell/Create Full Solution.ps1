
$scriptStartTime = (Get-Date)

Write-Host "Script Start Time: $scriptStartTime"

#*************************************************************************
# MADATORY VARIABLE ENTRY
#*************************************************************************

<# rootName value will be prepended to many other values. 
Please make sure this value only includes lower case letters and numbers.
Value should be kept as short as possible while still conveying meaning #>
$rootNameValue = "lttlhlp"

# Location where the solution files are stored
$rootSourceFileLocation = "C:\Users\mavail\OneDrive - Microsoft\GitHub\ALittleHelpWithBigData"

# Subscription ID for the Azure Subscription that will house the solution
$azureSubscriptionIDValue = "39266f84-b3d9-4256-98bb-c7573ce230df"

# Name of the Azure Automation account that will be used for this solution
$automationAccountName = "Automation"

# Name of the resource group to which the Azure Automation account belongs
$automationResourceGroup = "AutomationRG"

#*************************************************************************
# END MADATORY VARIABLE ENTRY 
#*************************************************************************

<#

Login-AzureRmAccount

#>

"Selecting Azure Subscription..."
Select-AzureRmSubscription -Subscriptionid $azureSubscriptionIDValue

# Create function to get variable value
function GetAutomationVariableValue
{

    param
    (
        [string]$variableName
    )

    try
    {
        (Get-AzureRMAutomationVariable `
            -Name $variableName `
            -ResourceGroupName $automationResourceGroup `
            -AutomationAccountName $automationAccountName).Value
    }
    catch
    {
        Write-Error -Message $_.Exception
        throw $_.Exception
    }
}# Build Azure Automation Variable Names based on POCRootName
$resourceGroupNameVariable = "$($rootNameValue)ResourceGroupName"
$storageAccountNameVariable = "$($rootNameValue)StorageAccountName"
$rawFilesContainerVariable = "$($rootNameValue)RawFileContainerName"
$clusterStorageContainerVariable = "$($rootNameValue)ClusterStorageContainerName"
$sqlServerNameVariable = "$($rootNameValue)SQLServerName"
$genericActiveDirectoryAdminVariable = "$($rootNameValue)GenericActiveDirectoryAdmin"
$hiveScriptExecutionCompletedVariable = "$($rootNameValue)HiveScriptExecutionCompleted"
$sqlDWNameVariable = "$($rootNameValue)SQLDWName"
$tsqlScriptExecutionCompletedVariable = "$($rootNameValue)TSQLScriptExecutionCompleted"


$resourceGroupName = GetAutomationVariableValue -variableName $resourceGroupNameVariable
$storageAccountName = GetAutomationVariableValue -variableName $storageAccountNameVariable
$rawFilesContainer = GetAutomationVariableValue -variableName $rawFilesContainerVariable
$clusterStorageContainer = GetAutomationVariableValue -variableName $clusterStorageContainerVariable$sqlServerName = GetAutomationVariableValue -variableName $sqlServerNameVariable$genericActiveDirectoryAdmin = GetAutomationVariableValue -variableName $genericActiveDirectoryAdminVariable$hiveScriptExecutionCompleted = GetAutomationVariableValue -variableName $hiveScriptExecutionCompletedVariable$sqlDWName = GetAutomationVariableValue -variableName $sqlDWNameVariable$tsqlScriptExecutionCompleted = GetAutomationVariableValue -variableName $tsqlScriptExecutionCompletedVariable$hadoopStoragePath = "wasbs://$clusterStorageContainer@$storageAccountName.blob.core.windows.net"$sqlScriptsSourceLocation = "$rootSourceFileLocation\TSQL"# Create function to set variable value
function SetAutomationVariableValue
{

    param
    (
          [string]$variableName
        , [string]$variableValue
    )

    try
    {
        Set-AzureRMAutomationVariable `
            -Name $variableName `
            -ResourceGroupName $automationResourceGroup `
            -AutomationAccountName $automationAccountName `
            -Value $variableValue `
            -Encrypted $false
    }
    catch
    {
        Write-Error -Message $_.Exception
        throw $_.Exception
    }
}# Create function to run Hive query"
function RunHiveQuery
{
    param
    (
        [string]$hiveQueryString
    )

    try{
        If((Get-AzureRmHDInsightCluster `
                -ResourceGroupName $resourceGroupName `
                -ClusterName $clusterName `
                -ErrorAction SilentlyContinue))
        {

            $hiveJobDefinition = New-AzureRmHDInsightHiveJobDefinition `
                                    -Query $hiveQueryString       
        
            $hiveJob = Start-AzureRmHDInsightJob `
                        -ClusterName $clusterName `
                        -HttpCredential $clusterHTTPCredential `
                        -JobDefinition $hiveJobDefinition -OutVariable $hiveJobResult 
        
            $hiveJobID = $hiveJob.JobID
        
            Write-Host "Job ID: $hiveJobID" 
        
            Wait-AzureRmHDInsightJob `
                -ClusterName $clusterName `
                -HttpCredential $clusterHTTPCredential `
                -JobId $hiveJobID
        
            Get-AzureRmHDInsightJobOutput `
                -ClusterName $clusterName `
                -HttpCredential $clusterHTTPCredential `
                -JobId $hiveJobID
        
            "Hive Job Result:"

            $hiveJobResult
                                            

            #Write-Output "HDInsight Cluster $clusterName created successfully."

        }
        Else 
        {
            #Write-Output "HDInsight Cluster $clusterName already exists."
        } 
    }
    catch
    {
        Write-Error -Message $_.Exception
        throw $_.Exception
    }

}# Create function to Start Runbookfunction StartRunbook{    param    (        [string]$runBookName    )    Write-Host "Executing runbook $runBookName... `r`n"    try
    {
        If((Get-AzureRmAutomationRunbook `
            -AutomationAccountName $automationAccountName `
            -ResourceGroupName $automationResourceGroup `
            -Name $runBookName `
            -ErrorAction SilentlyContinue))   
        {
            Start-AzureRmAutomationRunbook `
                -AutomationAccountName $automationAccountName `
                -ResourceGroupName $automationResourceGroup `
                -Name $runBookName `                -Wait            Write-Host "Runbook $runBookName executed successfully. `r`n"        }        Else        {            Write-Host "Runbook $runBookName does not exist... `r`n"        }    }    catch
    {
        Write-Error -Message $_.Exception
        throw $_.Exception
    }}#*************************************************************************
# DERIVE RUNBOOK NAMES BASED ON  rootNameValue
#*************************************************************************$runbookParentCreatePermanentComponents = "$($rootNameValue)ParentCreatePermanentComponents"$runbookParentCreateHDInsightHadoopCluster = "$($rootNameValue)ParentCreateHDInsightHadoopCluster"$runbookParentExecuteHiveQuery = "$($rootNameValue)ParentExecuteHiveQuery"#*************************************************************************
# EXECUTE RUNBOOK TO CREATE PERMANENT SOLUTION COMPONENTS 
#*************************************************************************Write-Host "Starting runbook $runbookParentCreatePermanentComponents... `r`n"StartRunbook -runBookName $runbookParentCreatePermanentComponents#*************************************************************************
# SET ACTIVE DIRECTORY ADMIN FOR SQL DATABASE SERVER
#*************************************************************************

$sqlServerADAdmin = (Get-AzureRmSqlServerActiveDirectoryAdministrator -ResourceGroupName $resourceGroupName -ServerName $sqlServerName -ErrorAction SilentlyContinue).DisplayName

Write-Host "Setting $genericActiveDirectoryAdmin as the AD Admin for server $sqlServerName... `r`n"
if($sqlServerADAdmin -ne $genericActiveDirectoryAdmin)
{
    try
    {
        Set-AzureRmSqlServerActiveDirectoryAdministrator `
            -ResourceGroupName $resourceGroupName `
            -ServerName $sqlServerName `
            -DisplayName $genericActiveDirectoryAdmin `
            -ErrorAction Stop

        Write-Host "Setting $genericActiveDirectoryAdmin as the AD Admin for server $sqlServerName completed succesfully. `r`n"
    }
    catch
    {
        Write-Error -Message $_.Exception
        throw $_.Exception
    }

}
else
{
    Write-Host "$genericActiveDirectoryAdmin is already the AD Admin for server $sqlServerName. `r`n"
}

#*************************************************************************
# UPLOAD RAW DATA FILES TO STORAGE
#*************************************************************************# Uploading files#Local file system location of folder container the raw files to be uploaded
$rawFileSourceLocation = "$($rootSourceFileLocation)\Raw Files"Write-Host "Uploading source files"$storageAccountArray = Get-AzureRmStorageAccountKey `                            -ResourceGroupName $resourceGroupName `                            -Name $storageAccountName$storageAccountKey = $storageAccountArray.Item(0).Value$azureContext = New-AzureStorageContext `                    -StorageAccountName $storageAccountName `                    -StorageAccountKey $storageAccountKey


$files = Get-ChildItem $rawFileSourceLocation

"Begin processing files in $rawFileSourceLocation."

foreach ($file in $files) 
{

    "Upload $file to $rawFilesContainer"
    If(!($blob = Get-AzureStorageBlob -Blob $file -Container $rawFilesContainer -Context $azureContext -ErrorAction SilentlyContinue))
    {

        
        $fileName = "$rawFileSourceLocation\$file"
        $blobName = "$file"

        "Uploading $file"
        Set-AzureStorageBlobContent -Context $azureContext -Container $rawFilesContainer -File $filename

    }
    Else
    {
        "$file already exists in $rawFilesContainer."
    }

    "Copy $file to $clusterStorageContainer"

    $hadoopFilePath = "data\$($file.BaseName)\$file"

    If(!($blob = Get-AzureStorageBlob -Blob $hadoopFilePath -Container $clusterStorageContainer -Context $azureContext -ErrorAction SilentlyContinue))
    {

        "Copying $file..."
        Start-AzureStorageBlobCopy -SrcBlob $file -SrcContainer $rawFilesContainer -DestContainer $clusterStorageContainer -DestBlob $hadoopFilePath -Context $azureContext
    }
    Else
    {
        "$hadoopFilePath already exists in $clusterStorageContainer."
    }

    "Processing $file completed."
    " "

}

"All files in $rawFileSourceLocation successfully processed."#*************************************************************************
# EXECUTE RUNBOOK TO CREATE HDINSIGHT HADOOP CLUSTER
#*************************************************************************Write-Host "Starting runbook $runbookParentCreateHDInsightHadoopCluster... `r`n"StartRunbook -runBookName $runbookParentCreateHDInsightHadoopCluster#*************************************************************************
# EXECUTE RUNBOOK TO CREATE AND POPULATE HIVE TABLES
#*************************************************************************Write-Host "Starting runbook $runbookParentExecuteHiveQuery... `r`n"StartRunbook -runBookName $runbookParentExecuteHiveQuery#*************************************************************************
# CONFIGURE SQL DATA WAREHOUSE FOR EXTERNAL FILE ACCESS
#*************************************************************************if($tsqlScriptExecutionCompleted -eq "N"){    #*************************************************************************
    # CONFIGURE SQL DATA WAREHOUSE FOR EXTERNAL FILE ACCESS
    #*************************************************************************    Write-Host "Executing TSQL steps via SQLCMD to configure $sqlDWName for external file access for Polybase..."
    
    
    # Create active directory user

    Write-Host "Creating Database User for Active Directory user $genericActiveDirectoryAdmin..."     
   
    $sqlcmdCreateDBUser = "CREATE USER [$genericActiveDirectoryAdmin] FROM EXTERNAL PROVIDER;"

    sqlcmd -S "$sqlServerName.database.windows.net" -G -I -d $sqlDWName -Q $sqlcmdCreateDBUser

    Write-Host "Database User for Active Directory user $genericActiveDirectoryAdmin created successfully. `r`n"
  
    
    # Create database master key

    Write-Host "Creating database master key..."

    sqlcmd -S "$sqlServerName.database.windows.net" -G -I -d $sqlDWName -Q "CREATE MASTER KEY;"

    Write-Host "Database master key created successfully. `r`n"

    
    # Create database scoped credential

    Write-Host "Creating database scoped credential..."
    
    $sqlcmdCredential = "CREATE DATABASE SCOPED CREDENTIAL AzureStorageCredential WITH IDENTITY = 'user', SECRET = '$storageAccountKey';"

    sqlcmd -S "$sqlServerName.database.windows.net" -G -I -d $sqlDWName -Q $sqlcmdCredential

    Write-Host "Database scoped credential created successfully. `r`n"


    # Create external data source

    Write-Host "Creating external data source for $hadoopStoragePath..."
    
    $sqlExtDataSource = "CREATE EXTERNAL DATA SOURCE AzureStorage
	    WITH (
		    TYPE = HADOOP,
		    LOCATION = '$hadoopStoragePath',
		    CREDENTIAL = AzureStorageCredential
	    )"

    sqlcmd -S "$sqlServerName.database.windows.net" -G -I -d $sqlDWName -Q $sqlExtDataSource

    Write-Host "External data source for $hadoopStoragePath created successfully. `r`n"
    
    
    # Create external file format for ORC files

    Write-Host "Creating external file format for Orc files..."
    
    $sqlExtFileFormatOrc = "CREATE EXTERNAL FILE FORMAT orcfile  
	    WITH (  
		    FORMAT_TYPE = ORC,  
		    DATA_COMPRESSION = 'org.apache.hadoop.io.compress.SnappyCodec'  
	    )"

    sqlcmd -S "$sqlServerName.database.windows.net" -G -I -d $sqlDWName -Q $sqlExtFileFormatOrc

    Write-Host "external file format for Orc files created successfully. `r`n"
    
    
    # Create external file format for TEXT files

    Write-Host "Creating external file format for Text files..."

    $sqlExtFileFormatText = "	CREATE EXTERNAL FILE FORMAT textfile  
	    WITH (  
		    FORMAT_TYPE = DELIMITEDTEXT  
		    , FORMAT_OPTIONS (FIELD_TERMINATOR = '|') 
	    )"

    sqlcmd -S "$sqlServerName.database.windows.net" -G -I -d $sqlDWName -Q $sqlExtFileFormatText

    Write-Host "external file format for Text files created successfully. `r`n"

    Write-Host "TSQL steps via SQLCMD to configure $sqlDWName for external file access for Polybase completed successfully. `r`n"
    
    #*************************************************************************
    # CRETE SQL DATA WAREHOUSE TABLES AND VIEWS
    #*************************************************************************

    # Execute script to create and populates tables and create views

    Write-Host "Executing TSQL script to create and populate tables and create views..."        sqlcmd -S "$sqlServerName.database.windows.net" -G -I -i "$sqlScriptsSourceLocation\SQL DW Master.sql" -d $sqlDWName        #*************************************************************************
    # SET tsqlScriptExecutionCompleted VARIABLE ASSET TO "Y" TO SCRIPT WILL NOT EXECUTE AGAIN
    #*************************************************************************            SetAutomationVariableValue -variableName $tsqlScriptExecutionCompletedVariable -variableValue "Y"    Write-Host "TSQL script to create and populate tables and create views executed successfully. `r`n"}else{    Write-Host "TSQL executed previously."}$scriptEndTime = (Get-Date)

Write-Host "Script End Time: $scriptEndTime"

$scriptExecutionDuration = New-TimeSpan -Start $scriptStartTime -End $scriptEndTime

$scriptExecutionDurationHours = $scriptExecutionDuration.Hours
$scriptExecutionDurationMinutes = $scriptExecutionDuration.Minutes
$scriptExecutionDurationSeconds = $scriptExecutionDuration.Seconds

Write-Host "Total script execution duration: $scriptExecutionDurationHours : $scriptExecutionDurationMinutes : $scriptExecutionDurationSeconds"