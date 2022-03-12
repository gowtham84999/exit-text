[CmdletBinding()]
param (
     $deploymentName,$vnetName,$subnetName,$vnet_RG,$vnet_ResourceId,$whitelistips,$storage_account_RG,$location,$tag,$storage_account_Name,$isLockEnabled,$storage_account_accountType,$storage_account_AccessTier,$storage_account_kind,$isSoftDeleteEnabled,$softDeleteRetentionDays,$Keyvault_name,$keyvault_RG,$ADGroup,$Application_ID,$supportsHttpsTrafficOnly,$isBlobsupported,$Lockoperation,$LockName,$advancedThreatProtectionEnabled,$role,$isroleEnabled
     )
try{
$networks = @(@{"vnet" = $vnetName; "subnet" = $subnetName;"vnetrg" = $Vnet_RG;"resourceId" = $vnet_ResourceId})
$whitelistipaddresses = @($whitelistips)
[bool]$t =$true
[bool]$f =$false
$WebhookData = @{"resourceGroup" = $storage_account_RG;"location" = $location;"deploymentName" = $deploymentName; "templateFile" = "cloud-platform-automation-assets/azure/Storage Provisioning/Storage_Prov.json";"tags" = @{"owner" = $tag};"storageAccountName" = $storage_account_Name;"accountType" = $storage_account_accountType;"AccessTier" = $storage_account_AccessTier;"kind" = $storage_account_kind;"LargefileShare" = "";"supportsHttpsTrafficOnly" = [System.Convert]::ToBoolean($supportsHttpsTrafficOnly);"isSoftDeleteEnabled" = [System.Convert]::ToBoolean($isSoftDeleteEnabled);"softDeleteRetentionDays" = [int]$softDeleteRetentionDays;"isBlobsupported" = [System.Convert]::ToBoolean($isBlobsupported);"isLockEnabled" = [System.Convert]::ToBoolean($isLockEnabled);"LockName" = $LockName;"Lockoperation" = $Lockoperation;"advancedThreatProtectionEnabled" = [System.Convert]::ToBoolean($advancedThreatProtectionEnabled);"keyvaultname" = $Keyvault_name;"keyvaultRGname" = $keyvault_RG;"keyvaultsecretkey1" = "sakey1";"keyvaultsecretkey2" = "sakey2";"group" = $ADGroup;"role" = $role;"isroleEnabled" = [System.Convert]::ToBoolean($isroleEnabled);"whitelistipaddresses" = $whitelistipaddresses;"Networks" = $networks; "ApplicationID" = $Application_ID}
$WebhookData
$jobOutput = cloud-platform-automation-assets/azure/'Storage Provisioning'/Storage_Account_Creation_Git.ps1 $WebhookData
$jobOutput.ForEach({
if ($null -ne $_ -and 'Hashtable' -eq $_.getType().Name) {
if ($_.ContainsKey("DeploymentName") -and $_.ContainsKey("Outputs") -and $_.ContainsKey("Provisioningstate")) {
$delpoymentStatus = $_ | ConvertTo-Json
Write-Output 'Job Output is :'$delpoymentStatus
Write-Output 'provisioning state : '$_.Provisioningstate
if ($_.Provisioningstate -eq "Failed") {
throw $_ | ConvertTo-Json
}
}
}
})
}catch{
Write-Output "Error caught in Master Deployment Script:"
Write-Output $_
$provisioningstate = "Failed"
$reason = $_.Exception.Message
Write-Output $_.ErrorDetails
Write-Output $_.ScriptStackTrace
$host.SetShouldExit(-1)
}
