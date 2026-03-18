##
# Get-CurrentUser.ps1
# Description: This script retrieves the username of the currently logged-in user on a specified remote computer. It uses WMI to query the Win32_ComputerSystem class and extracts the UserName property, which contains the domain and username of the logged-in user.
# Parameters:
#    -TargetComputer: The name of the remote computer to retrieve the current user from
# Example usage:
#    .\Get-CurrentUser.ps1 -TargetComputer "RemotePC"
##

[CmdletBinding()]
param (
    [Parameter(Mandatory = $true)]
    [string]$TargetComputer
)

Write-Host ""
Write-Host "Retrieving current logged-in user from $TargetComputer..." -ForegroundColor Green
try {
    $computerSystem = Get-WmiObject -Class Win32_ComputerSystem -ComputerName $TargetComputer
    if ($computerSystem) {
        $currentUser = $computerSystem.UserName
        if ($currentUser) {
            Write-Host "Current logged-in user on $TargetComputer-> $currentUser" -ForegroundColor Green
        }
        else {
            Write-Host "No user is currently logged in on $TargetComputer." -ForegroundColor Yellow
        }
    }
    else {
        Write-Host "Failed to retrieve computer system information from $TargetComputer." -ForegroundColor Red
    }
}
catch {
    Write-Host "Error retrieving current user from $TargetComputer : $($_.Exception.Message)" -ForegroundColor Red
}