[CmdletBinding()]
param (
   $deploymentName,$enablePostProvisioning,$enableDiagnostics,$noOfDisks,$dataDiskDetails,$subscription,$nessuskey,$rapid7key,$keyVaultName,$ApplicationID,$Location,$tag,$keyVault_RG,$storage_account_name,$vm_name,$environmentCode,$vm_RG,$storage_account_RG,$osType,$enableEncryption,$driveLetter,$drive_size,$AutomationAccount_name,$AutomationAccount_RG,$AutomationAccount_Subsciption,$portfolioCode,$volumeType,$locationCode,$OUpath,$DomainName,$admingrouplist,$readergrouplist,$portfolio,$OUTier,$ADAdminGroup,$ADReaderGroup
)
try{
if ($osType -eq 'Windows') {
$postprovisionscriptFiles = @(
@{
"Name" = "cloud-platform-automation-assets/azure/Compute_Provisioning/PostProvision Scripts/DiskPartition.ps1";
"Variables"= @{
              "driveLetter" = $driveLetter
              "size" = $drive_size
              }},
@{
"Name"= "cloud-platform-automation-assets/azure/Compute_Provisioning/PostProvision Scripts/adgroupaddition.ps1";
"Variables"=@{
              "admingrouplist"= $admingrouplist;
              "readergrouplist"= $readergrouplist
               }})
             }

elseif ($osType -eq 'Linux') {
$postprovisionscriptFiles = @(
@{
"Name" = "cloud-platform-automation-assets/azure/Compute_Provisioning/PostProvision Scripts/DiskPartition.sh";
"Variables" = @{ "dataDiskDetails" = '$dataDiskDetails'}}
)}


$Extensionparams = @{"getpasswdsecretparamsFile"="cloud-platform-automation-assets/azure/Compute_Provisioning/PostProvision Scripts/domainsecparam.json";"getpasswdsecretFile"="cloud-platform-automation-assets/azure/Compute_Provisioning/PostProvision Scripts/domainpassec.json";"deploymentname" = $deploymentName;"templateFile" = "cloud-platform-automation-assets/azure/Compute_Provisioning/Extensions/VM_Extension_ARM_Template.json";"ExtensionContructor" = "cloud-platform-automation-assets/azure/Compute_Provisioning/Extensions/VM_Extensions_Construct_ADDomain.ps1";"location" = $Location;"resourceGroup" = $vm_RG;"tags"=@{"Owner" = $tag};"virtualMachineName" = $vm_name;"osType"=$osType;"enablePostProvisioning"=[System.Convert]::ToBoolean($enablePostProvisioning);"enableDiagnostics"=[System.Convert]::ToBoolean($enableDiagnostics);"noOfDisks"=[int]$noOfDisks;"resourceName"=$vm_name;"resourceType"="vm";"enableEncryption"=[System.Convert]::ToBoolean($enableEncryption);"diagnoticsStorageAccount"=$storage_account_name;"diagnoticsStorageAccountRg"=$storage_account_RG;"diskKeyVaultRg"=$keyVault_RG;"diskKeyVaultName"=$keyVaultName;"kekName"="";"kekversion"="";"volumeType"=$volumeType;"postprovisionscriptFiles"=$postprovisionscriptFiles;"subscription"=$subscription;"portfolioCode"= $portfolioCode;"postProvAutomationAccount" = @{"name" = $AutomationAccount_name;"resourceGroup" = $AutomationAccount_RG;"subscription" = $AutomationAccount_Subsciption};"environmentCode" = $environmentCode;"locationCode"=$locationCode;"OUpath"=$OUpath;"DomainName" =$DomainName;"portfolio"=$portfolio;"ADAdminGroup"=$ADAdminGroup;"ADReaderGroup"=$ADReaderGroup;"OUTier" =$OUTier}
$Extensionparams
$jobOutput = cloud-platform-automation-assets/azure/Compute_Provisioning/Extensions/VM_Extension_ProvisionScript.ps1 $Extensionparams
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
