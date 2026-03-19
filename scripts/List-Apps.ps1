##
# List-Apps.ps1
# Description: This script lists all installed apps on the local computer
#
# Parameters:
#    None
# Example usage:
#    .\List-Apps.ps1
##

Write-Host "Listing all installed apps on the local computer..." -ForegroundColor Green
try {
    $apps = Get-AppxPackage
    if ($apps) {
        Write-Host "Installed apps retrieved successfully!" -ForegroundColor Green
        Write-Host ""
        $apps | Select-Object Name, PackageFullName | Format-Table -AutoSize
    }
    else {
        Write-Host "No installed apps found on the local computer."
    }
}
catch {
    Write-Host "Failed to retrieve installed apps: $($_.Exception.Message)" -ForegroundColor Red
}
