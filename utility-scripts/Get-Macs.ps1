##
# Get-Macs.ps1
# Description: This script retrieves the MAC addresses of all network adapters on a specified remote computer and displays them in a formatted table.
# Parameters:
#    -TargetComputer: The name of the remote computer to retrieve the MAC addresses from
# Example usage:
#    .\Get-Macs.ps1 -TargetComputer "RemotePC"
##

[CmdletBinding()]
param (
    [Parameter(Mandatory = $true)]
    [string]$TargetComputer
)

Write-Host ""
Write-Host "Retrieving MAC addresses from $TargetComputer..." -ForegroundColor Green
try {
    $networkAdapters = Get-WmiObject -Class Win32_NetworkAdapter -ComputerName $TargetComputer
    if ($networkAdapters) {
        Write-Host "MAC addresses retrieved successfully!" -ForegroundColor Green
        Write-Host ""
        $networkAdapters | Select-Object Name, MACAddress | Format-Table -AutoSize
    }
    else {
        Write-Host "No network adapters found on $TargetComputer"
    }
}
catch {
    Write-Host "Failed to retrieve MAC addresses from $TargetComputer : $($_.Exception.Message)" -ForegroundColor Red
}

