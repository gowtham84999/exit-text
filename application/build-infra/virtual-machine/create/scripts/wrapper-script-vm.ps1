[CmdletBinding()]
param (
    $deploymentName,$availabilityOptions,$osType,$vmSize,$enableBootDiagnostics,$authenticationType,$adminUsername,$imageType,$privateImageId,$osDiskCaching,$osDiskCreateOption,$osDiskSizeGB,$keyVaultName,$ApplicationID,$Location,$tag,$vm_RG,$nicName,$storage_account_name,$vm_name,$imagePublisher,$imageOffer,$imageSku,$imageVersion,$nic_RG,$key_Vault_RG,$storage_account_RG
)
try{
$scriptParams = @{"PasswordGenerator" = "cloud-platform-automation-assets/azure/Common_Script/PasswordGenerator.ps1";"secretTemplateFile" = "cloud-platform-automation-assets/azure/KeyVault Secret/Secret_ARM_Template.json";"keyVaultAccessPolicyFile" = "cloud-platform-automation-assets/azure/Common_Script/Update-KeyVaultAccess.ps1";"resourceGroup" = $vm_RG;"location" = $Location;"deploymentName" = $deploymentName;"templateFile" = "cloud-platform-automation-assets/azure/Compute_Provisioning/Virtual Machine/VM_ARM_Template.json";"virtualMachineName" = $vm_name;"tags" = @{"Owner" = $tag};"availabilityOptions" = $availabilityOptions;"osType" = $osType;"vmSize" = $vmSize;"nicName" = $nicName;"enableBootDiagnostics" = [System.Convert]::ToBoolean($enableBootDiagnostics);"bootDiagnosticStorageAccount" = $storage_account_name;"bootDiagnosticStorageAccountRg" = $storage_account_RG;"authenticationType" = $authenticationType;"adminUsername" = $adminUsername;"imageType" = $imageType;"privateImageId" = $privateImageId;"osDiskCaching" = $osDiskCaching;"osDiskCreateOption" = $osDiskCreateOption;"osDiskSizeGB" = [int]$osDiskSizeGB;"keyVaultName" = $keyVaultName;"keyVaultRg" = $key_Vault_RG;"contentType" = "password";"enableSecret" = $true;"ApplicationID" = $ApplicationID}
$scriptParams
$jobOutput = cloud-platform-automation-assets/azure/Compute_Provisioning/'Virtual Machine'/VM_ProvisionScript.ps1 $scriptParams
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
