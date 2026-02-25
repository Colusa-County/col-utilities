

# Get all installed apps
$installedApps = Get-AppxPackage -AllUsers

# remove all apps for all users
foreach ($app in $installedApps) {
    try {
        Remove-AppxPackage -Package $app.PackageFullName -AllUsers -ErrorAction Stop
        Write-Host "Removed app: $($app.Name)"
    } catch {
        Write-Warning "Failed to remove app: $($app.Name). Error: $_"
    }
}

# Reinstall all built-in apps for all users
try {
    Get-AppxPackage -AllUsers | ForEach-Object {
        Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml" -ErrorAction Stop
        Write-Host "Reinstalled app: $($_.Name)"
    }
} catch {
    Write-Warning "Failed to reinstall apps. Error: $_"
}

Write-Host "App corruption fix process completed."