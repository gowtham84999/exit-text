[CmdletBinding()]
param (
    $deploymentName,$nsg_name,$nsg_rule_name,$nsg_RG,$nsg_rule_description,$nsg_protocal,$networkaccess,$direction,$sourcePortRange,$destinationPortRange,$sourceAddressPrefix,$destinationAddressPrefix,$priority
)
try{
$nsgparams = @{"resourceGroup" = $nsg_RG;"deploymentname" = $deploymentName;"templateFile" = "cloud-platform-automation-assets/azure/Network Resources/Network Security Group/NSG_Rules_ARM_Template.json";"nsgName" = $nsg_name;"ruleName" = $nsg_rule_name ;"ruleDescription" = $nsg_rule_description;"protocol" = $nsg_protocal;"networkAccess" = $networkaccess;"priority" = [int]$priority;"direction" = $direction;"sourcePortRange" = $sourcePortRange;"destinationPortRange" = $destinationPortRange;"sourceAddressPrefix" = $sourceAddressPrefix;"destinationAddressPrefix" = $destinationAddressPrefix}
$jobOutput = cloud-platform-automation-assets/azure/'Network Resources'/'Network Security Group'/NSG_Rules_ProvisionScript.ps1 $nsgparams
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
