$appName = "Acrobat"
$paths = @(
    'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall',
    'HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall'
)

$app = Get-ChildItem -Path $paths | Get-ItemProperty | Where-Object { $_.DisplayName -like "*$appName*" }

if ($app) {
    Write-Host "Found: $($app.DisplayName)"
    Write-Host "Uninstall String: $($app.UninstallString)"
}
else {
    Write-Host "Program not found."
}