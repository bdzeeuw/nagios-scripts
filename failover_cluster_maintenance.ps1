# Example: .\Cluster_Maintenance_Script.ps1 -ClusterNode "OPS-HV-005"
Param 
(
    [Parameter(Mandatory = $true)]
    [String[]]$ClusterNode
)

$CurrentTime = Get-Date -Format HH:mm
$ClusterName = "clustername"
# set down-time in Nagios
try {
Import-Csv $L3Config.ServerList | ? {$_.ComputerName -eq $ClusterNode} | Set-NagiosDowntime -Comment "Node drain + restart" -Start $CurrentTime -Duration 0.1:0:0 -Confirm:$False
}

catch {
        "error in setting down-time"}
Start-Sleep -s 5
# suspend/Pause Cluster Node with Drain (so all VM's are automaticly live migrated among other hosts
try {
Suspend-ClusterNode $ClusterNode -Cluster $ClusterName -Drain
}
catch {
        "error suspending ClusterNode $ClusterNode"}
# wait 5 minutes for all live migrations to complete       
Start-Sleep -s 300
# if cluster state is paused, restart the cluster node (cluster state pause means all roles have been migrated)
$ClusterState = Get-ClusterNode $ClusterNode -Cluster $ClusterName | select State
if ($ClusterState -match "Paused") 
{
    Restart-Computer -ComputerName $ClusterNode -Force
}
else
{
    Write-Output "Cluster node $ClusterNode is not paused, action required"
    Break
}
# wait 15 minutes for the machine to restart
Start-Sleep -s 900
$ClusterState2 = Get-ClusterNode $ClusterNode -Cluster $ClusterName | select State
if ($ClusterState2 -match "Paused") 
{
    Resume-ClusterNode $ClusterNode -Cluster $ClusterName -Failback Immediate
}
else
{
    Write-Output "Cluster node $ClusterNode is not paused after reboot, action required"
    Break
}
# wait 3 minutes for the fallback of the roles
Start-Sleep -s 180
# check if the cluster state is up/OK again
$ClusterState3 = Get-ClusterNode $ClusterNode -Cluster $ClusterName | select State
if ($ClusterState3 -match "Up") 
{
    Write-Output "Cluster node $ClusterNode is up again"
}
else
{
    Write-Output "Cluster node $ClusterNode has not resumed, action required!"
    Break
}
