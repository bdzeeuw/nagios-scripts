Try {
$CheckCollectionName = "Example Collection"
$SessionHosts = Get-RDSessionHost -collectionname $CheckCollectionName | Select NewConnectionAllowed
}
Catch {
"WARNING: could not retreive session host information"
}
if ($SessionHosts -match 'No') {
    Write-Output "CRITICAL: one or more SessionHosts do not allow new connections"
 }
  else {            
    Write-Output "OK: all SessionHosts allow new connections"
}    
