# Basic script to check the cluster node state
# Example: .\check_cluster_node.ps1 -ClusterNode "localhost" -ClusterName "clustername.domain.tld" 
(
    [Parameter(Mandatory = $true)]
    [String[]]$ClusterNode,
    [String[]]$ClusterName
)
Try {
$ClusterState = Get-ClusterNode $ClusterNode -Cluster $ClusterName | select State
}
Catch {
    Write-Output "UNKNOWN: could not retreive cluster node state information"
}
foreach ($ClusterState in $ClusterState) 
{
if ($ClusterState -match 'Paused') 
{
    Write-Output "Critical: cluster node is paused!"
    Break
 }
elseif ($ClusterState -match 'Pausing') 
{
    Write-Output "WARNING: cluster is draining!"
    Break
 }
elseif ($ClusterState -match 'Down') 
{
    Write-Output "CRITICAL: cluster node is down!"
    Break
 }
elseif ($ClusterState -match 'Up') 
{
    Write-Output "OK: cluster node is up!"
    Break
 }
else
 {
    Write-Output "UNKNOWN: no state matched"
 }
}
