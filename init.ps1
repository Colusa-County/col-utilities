winget install --id Microsoft.PowerShell --source winget -h --accept-package-agreements --accept-source-agreements --disable-interactivity
git pull
Clear-Screen
write-host "initiating ..."
Start-Process pwsh -Verb RunAs -ArgumentList '-File "./cutil.ps1"'
exit