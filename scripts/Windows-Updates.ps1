clear
write-host "initiating update check ..."

Install-Module PSWindowsUpdate -Force
Install-WindowsUpdate -MicrosoftUpdate -AcceptAll -IgnoreReboot

