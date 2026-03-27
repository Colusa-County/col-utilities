##
# @file         install-bginfo.ps1
# @date         6/25/2025
# @description  This script simply copies the bginfo files to the correct location on
#               a workstation to implement the software. Run it from the directory
#               that the bginfo files sit in, the software network folder.
#               Technically this script should work from anywhere on the target
#               machine.
##

Write-Host "Local(1), Local Public(2) or CCSO(3)? \n Default is Local"
# todo: Add options for each type of BGinfo install.

$TargetPath = "\\col-itfs1\it common\bginfo"
$LocalDrive = "C:\"
$BGInfoPath = "C:\bginfo"
$StartupPath = "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\StartUp"
$WorkstationLocal = "Workstation Info - Local.lnk"


# Copy bginfo folder to C drive
Copy-Item -Recurse -Path $TargetPath -Destination $LocalDrive

# Copy shortcut file
$ShortcutPath = Join-Path $BGInfoPath $WorkstationLocal
Copy-Item -Path $ShortcutPath -Destination $StartupPath