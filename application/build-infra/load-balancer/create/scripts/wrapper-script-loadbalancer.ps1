[CmdletBinding()]
param (
    $deployment,$lbName,$RG,$location,$tag,$vnetName,$subnet_Name,$lb_frontend_name,$storage_account_name
)
try{
$scriptParamsVal = @{"deploymentName" = $deployment;"rgName" = $RG;"lbName" = $lbName;"lbLocation" = $location;"sku" = "Standard";"lbType" = "Internal"; "vnetName" = $vnetName ;"subnetName" = $subnet_Name ;"tags" = @{"Owner"=$tag};"lb_frontend_name" = $lb_frontend_name;"vnetRgName" = $RG;"ipAssignment" = "Dynamic";"templateFile" = "cloud-platform-automation-assets/azure/Load Balancer/LB_Frontend_V1.json";"diaglogstgaccnt"= $storage_account_name;"diagstgaccntrg" = $RG}
$jobOutput = cloud-platform-automation-assets/azure/'Load Balancer'/LB_FrontendProvisioning.ps1 $scriptParamsVal
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
}
