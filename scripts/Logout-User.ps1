##
# Logout-User.ps1
# Description: This script logs out the currently logged-in user from a specified remote computer.
# Parameters:
#    -TargetComputer: The name of the remote computer to log out the user from
# Example usage:
#    .\Logout-User.ps1 -TargetComputer "RemotePC"
##

[CmdletBinding()]
param (
    [Parameter(Mandatory = $true)]
    [string]$TargetComputer
)

Write-Host ""
Write-Host "Logging out current user from $TargetComputer..." -ForegroundColor Green
try {
    $computerSystem = Get-WmiObject -Class Win32_ComputerSystem -ComputerName $TargetComputer
    if ($computerSystem) {
        $currentUser = $computerSystem.UserName
        if ($currentUser) {
            Write-Host "Logging out user $currentUser from $TargetComputer..." -ForegroundColor Green
            # Implementation for logging out the user would go here
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
    Write-Host "Error logging out user from $TargetComputer : $($_.Exception.Message)" -ForegroundColor Red
}