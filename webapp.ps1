param( 
    [string]$resourcegroupname = 'uday-work-resourcegroup',
    [string]$name = 'webappscal',
    [string]$location = 'south india',
    [string]$tier = 'standard',
    [string]$appserviceplan = 'webappplan',
    [string]$keyvaultname = 'webappscal-key',
    [string]$vaultname = 'webappscal-key',
    [string]$secretname = 'udayakumarp',
    [string]$serviceprincipalname = 'scalablesolutions',
    [string]$password = 'Awesome@123456789',
    [string]$azureAplicationId = "ca245b35-def4-448e-902d-79dfd243bd6c"
)

# $clientId= "ca245b35-def4-448e-902d-79dfd243bd6c"
# $clientsecret= "cbV8Q~qohcXlXbh9toIlZA6QSlIIAqniH7qeObaI"
# $subscriptionId= "0a2c8369-a730-408a-b37c-413746bcea56"
# $tenantId= "4d00a68f-24f7-4b96-8b19-fe052c4e49b1"

# azure login using serviceprincipal start
$azureAplicationId = "ca245b35-def4-448e-902d-79dfd243bd6c"
$azureTenantId = "4d00a68f-24f7-4b96-8b19-fe052c4e49b1"
$azurePassword = ConvertTo-SecureString "Awesome@123" -AsPlainText -Force
$psCred = New-Object System.Management.Automation.PSCredential($azureAplicationId , $azurePassword)
Add-AzAccount -Credential $psCred -TenantId $azureTenantId  -ServicePrincipal
# azure login using serviceprincipal succesfull 

$StartTime = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss.fff")

try {
    write-host 'create webapp start'
    New-AzWebApp -resourcegroupname $resourcegroupname -name $name -appserviceplan $appserviceplan  -location $location
    write-host 'createwebapp sucessful'
             	
}
catch {
	
    Write-Error 'create webapp sucessful' 
    throw $_.Exception.Message
}


try {
    write-host 'create appserviceplan start'
    new-Azappserviceplan -resourcegroupname $resourcegroupname  -name $name  -location $location  -tier $tier
    write-host 'create appserviceplan sucessful'
             	
}
catch {
	
    Write-Error 'create appserviceplan sucessful' 
    throw $_.Exception.Message
}

try {
    write-host 'create keyvault start'
    New-AzKeyVault -Name $keyvaultname -ResourceGroupName $resourcegroupname -Location $location
    write-host 'create keyvault sucessful'
             	
}
catch {
	
    Write-Error 'create keyvault sucessful' 
    throw $_.Exception.Message
}

try {
    write-host 'create system-assigned identity for App Service start'
    Set-AzWebApp -AssignIdentity $true -Name $name  -ResourceGroupName $resourcegroupname
    write-host 'create system-assigned identity for App Service sucessful'
             	
}
catch {
	
    Write-Error 'create system-assigned identity for App Service sucessful' 
    throw $_.Exception.Message
}

try {
    write-host 'create keyvaultaccesspolicy start'
    Get-AzContext
    Set-AzKeyVaultAccessPolicy -VaultName $keyvaultname -ServicePrincipalName $azureAplicationId  -PermissionsToSecrets get, list, set, delete -PassThru
    write-host 'create keyvaultaccesspolicy sucessful'
             	
}
catch {
	
    Write-Error 'create keyvaultaccesspolicy sucessful' 
    throw $_.Exception.Message
}

try {
    write-host 'create setkeyvaultsecret start'
    $Secret = ConvertTo-SecureString -String 'Password' -AsPlainText -Force
    Set-AzKeyVaultSecret -VaultName $vaultname -Name $secretname  -SecretValue $Secret
    write-host 'create setkeyvaultsecret sucessful'
             	
}
catch {
	
    Write-Error 'create setkeyvaultsecret sucessful' 
    throw $_.Exception.Message
}

try {
    write-host 'create getkeyvaultsecret start'
    Get-AzKeyVaultSecret -VaultName $vaultname  -Name $secretname -AsPlainText 
    write-host 'create getkeyvaultsecret sucessful'
             	
}
catch {
	
    Write-Error 'create getkeyvaultsecret sucessful' 
    throw $_.Exception.Message
}

try {
    write-host 'publish .net application into webapp start'
    $app = Get-AzWebApp -ResourceGroupName $resourcegroupname -Name $name
    Publish-AzWebApp -webapp $app -ArchivePath "C:\Users\P Uday Kumar\engineering-blog-samples\AspDotNetCore\AzureKeyVaultDemo.zip"
    write-host 'publish .net application into webapp sucessful'
             	
}
catch {
	
    Write-Error 'create system-assigned identity for App Service sucessful' 
    throw $_.Exception.Message
}
finally {
    $EndTime = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss.fff")
    
    $TimeDiff = New-TimeSpan -Start $StartTime -End $EndTime 
    Write-Output "Total time taken to deploy $stepName package : $($TimeDiff.ToString("hh':'mm':'ss"))"
    write-host "***********************************************************************************" 
    write-host "Total time taken to deploy $stepName package : $($TimeDiff.ToString("hh':'mm':'ss"))" 
    write-host "***********************************************************************************"
}