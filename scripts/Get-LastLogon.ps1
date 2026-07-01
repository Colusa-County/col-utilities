[CmdletBinding()]
param (
    [Parameter(Mandatory=$true)]
    [string]$TargetMachine
)

Get-ADComputer -Identity $TargetMachine -Properties LastLogonTimeStamp | Select-Object Name, @{Name="LastLogonTimeStamp"; Expression={[DateTime]::FromFileTime($_.LastLogonTimeStamp)}}