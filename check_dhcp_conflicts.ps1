$currentDay = Get-Date -u %a
$LogName = "DhcpSrvLog-"
$Combined = $LogName + $currentDay
Try {
$Content = Get-Content C:\Windows\system32\dhcp\$Combined.log | ? { ($_ | Select-String "BAD_ADDRESS")}  
}
Catch {
Write-Output "UNKNOWN: Unable to parse log"
}
if ($Content -match 'Conflict') 
{
    Write-Output "CRITICAL: DHCP conflicts detected: $Content "
    Break
 }
elseif ($Content -notmatch 'Conflict') 
{
    Write-Output "OK: no conflicts detected"
    Break
 }
else
 {
    Write-Output "UNKNOWN: shouldn't reach this stage"
 }
