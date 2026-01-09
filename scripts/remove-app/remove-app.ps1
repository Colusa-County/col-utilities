# THIS DOESNT WORK, JUST TESTING

param(
    [array]$apps = ""
)

# list installed apps
# Get-AppxProvisionedPackage -Online | Select-Object DisplayName, PackageName

# uninstall apps
# Get-AppxPackage -AllUsers -Name $AppName | Remove-AppxPackage -AllUsers
foreach ($app in $apps)
{
    Write-Host "Uninstalling -> " $app "... "
    Get-AppxPackage -AllUsers -Name $app | Remove-AppxPackage -AllUsers
    Write-Host "Done :)"
}

Write-Host "All listed apps uninstalled for all users."