[CmdletBinding()]
param (
    $deploymentName,$subscription,$vm_name,$vm_RG,$recovery_vault_name,$recovery_vault_RG,$key_VaultName,$key_Vault_RG
)
try{
[bool]$enableBootDiagnostics
[System.Convert]::ToBoolean($enableBootDiagnostics)
$postparams = @{"deploymentName" = $deploymentName; "templateFile" = "cloud-platform-automation-assets/azure/Compute_Provisioning/PostProvision Scripts/PostProvision.ps1";"subscription"=$subscription;"vmName"=$vm_name;"resourceGroup"=$vm_RG;"vaultName"=$recovery_vault_name;"vaultResourceGroup"=$recovery_vault_RG;"Policy"="DefaultPolicy";"keyVaultName" = $key_VaultName;"keyVaultRGName"= $key_Vault_RG}
$jobOutput = cloud-platform-automation-assets/azure/Compute_Provisioning/'PostProvision Scripts'/PostProvision.ps1 $postparams
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
