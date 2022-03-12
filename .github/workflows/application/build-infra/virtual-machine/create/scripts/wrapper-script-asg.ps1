[CmdletBinding()]
param (
    $deploymentName,$Location,$tag,$asg_RG,$asgName
)

try{
$asgparams = @{"deploymentName" = $deploymentName; "templateFile" = "cloud-platform-automation-assets/azure/Network Resources/Application Security Group/ASG_ARM_Template.json";"asgLocation" = $Location;"tags" = @{"owner" = $tag};"resourceGroup" = $asg_RG;"asgName" = $asgName;}
$jobOutput = cloud-platform-automation-assets/azure/'Network Resources'/'Application Security Group'/ASG_ProvisionScript.ps1 $asgparams
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
