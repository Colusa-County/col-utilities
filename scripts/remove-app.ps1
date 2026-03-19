##
# Remove-App.ps1
# Description: This script uninstalls an app using its package name. It uses the Get-AppxPackage cmdlet to find the app by name and then calls Remove-AppxPackage to uninstall it from the system.
# Parameters:
#    -PackageName: The name of the app package to uninstall (e.g., "Microsoft.ZuneMusic")
# Example usage:
#    .\Remove-App.ps1 -PackageName "Microsoft.ZuneMusic"
##

[CmdletBinding()]
param (
    [Parameter(Mandatory = $true)]
    [string]$PackageName
)

Write-Host "Attempting to uninstall app with package name: $PackageName" -ForegroundColor Green
try {
    $appPackage = Get-AppxPackage -Name $PackageName -ErrorAction Stop
    if ($appPackage) {
        Remove-AppxPackage -Package $appPackage.PackageFullName -ErrorAction Stop
        Write-Host "App uninstalled successfully: $PackageName" -ForegroundColor Green
    }
    else {
        Write-Host "App not found: $PackageName" -ForegroundColor Yellow
    }
}
catch {
    Write-Host "Failed to uninstall app: $($_.Exception.Message)" -ForegroundColor Red
}