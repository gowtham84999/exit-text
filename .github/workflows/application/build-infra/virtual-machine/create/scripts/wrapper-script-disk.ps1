[CmdletBinding()]
param (
    $deploymentName,$tag,$Location,$disk_RG,$disk1_Name,$disk1_Size,$disk1_lun,$disk1_caching,$disk2_Name,$disk2_Size,$disk2_lun,$disk2_caching,$diskSku,$zones,$attachDisk,$vm_name
)
try{

$DiskDetails = @(
    [pscustomobject]@{DiskName=$disk1_Name;DiskSize=[int]$disk1_Size;lun=[int]$disk1_lun;caching=$disk1_caching}
   # [pscustomobject]@{DiskName=$disk2_Name;DiskSize=[int]$disk2_Size;lun=[int]$disk2_lun;caching=$disk2_caching}
)
$DiskDetails
$diskparams = @{"deploymentName" = $deploymentName;"tags" = @{"Owner" = $tag};"templatePath" = "cloud-platform-automation-assets/azure/Compute_Provisioning/Disks/Disk_ARM_Template.json";"location" = $Location;"diskSku" = $diskSku;"zones" = [int]$zones;"resourceGroup" = $disk_RG;"attachDisk" = [System.Convert]::ToBoolean($attachDisk);"virtualMachineName" = $vm_name;"DiskDetails" = $DiskDetails}
$jobOutput = cloud-platform-automation-assets/azure/Compute_Provisioning/Disks/Disk_ProvisionScript.ps1 $diskparams
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
