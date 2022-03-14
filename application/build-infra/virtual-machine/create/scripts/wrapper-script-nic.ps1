[CmdletBinding()]
param (
    $deploymentName,$asg_name,$nic_RG,$asg_RG,$location,$tag,$nicName,$vnetName,$subnetName,$vnet_RG,$privateIPAllocationMethod
)
try{
$applicationSecurityGroupsval = @(@{"resourceGroup" = $asg_RG;"name" = $asg_name})
$nicparams = @{"deploymentName" = $deploymentName; "templateFile" = "cloud-platform-automation-assets/azure/Network Resources/Network Interface/NIC_ARM_Template.json";"nicLocation" = $location;"tags" = @{"owner" = $tag};"resourceGroup" = $nic_RG;"nicName" = $nicName;"privateIPAllocationMethod" = $privateIPAllocationMethod;"subneDetails" = @{"resourceGroup" = $vnet_RG;"vnetName" = $vnetName;"subnetName" = $subnetName};"applicationSecurityGroups" = $applicationSecurityGroupsval}
$jobOutput = cloud-platform-automation-assets/azure/'Network Resources'/'Network Interface'/NIC_ProvisionScript.ps1 $nicparams
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
