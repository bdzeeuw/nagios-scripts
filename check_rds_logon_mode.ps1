# Basic script to check the RDS Logon Mode
Try {
$RDSLogonMode = Get-WmiObject -Namespace "root\cimv2\TerminalServices" -Class Win32_TerminalServiceSetting | Select-Object SessionBrokerDrainMode
}
Catch {
    Write-Output "UNKNOWN: could not retreive session host information"
}
foreach ($RDSLogonMode in $RDSLogonMode) 
{
if ($RDSLogonMode -match '0') 
{
    Write-Output "OK: Logon mode is enabled"
    Break
 }
elseif ($RDSLogonMode -match '1') 
{
    Write-Output "WARNING: Logon mode is drain until restart"
    Break
 }
elseif ($RDSLogonMode -match '2') 
{
    Write-Output "CRITICAL: Logon mode is drained"
    Break
 }
elseif ($RDSLogonMode -match '3') 
{
    Write-Output "CRITICAL: Logon mode is disabled"
    Break
 }
else
 {
    Write-Output "UNKNOWN: no logon state matched"
 }
}
