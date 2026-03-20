##
# Backup.ps1
# Description: This script performs a backup of the specified user's Desktop, Documents, Pictures, Downloads, Videos, and Music folders. It uses Robocopy to copy the user's profile folder to the specified network location, preserving file attributes and permissions.
# Parameters:
#    -Username: The username of the profile to back up (e.g., "jdoe")
# Example usage:
#    .\Backup.ps1 -Username "jdoe"
##

[CmdletBinding()]
param (
    [Parameter(Mandatory = $true)]
    [string]$Username,

    [Parameter(Mandatory = $true)]
    [string]$BackupLocation

)

$UserProfilePath = "C:\Users\$Username"

$CurrentDate = Get-Date -Format "yyyy-MM-dd"
$BackupLocation = Join-Path -Path $BackupLocation -ChildPath "$Username`$"
$BackupDestination = Join-Path -Path $BackupLocation -ChildPath "Backup-$CurrentDate"

Write-Host "Preparing to back up profile for user: $Username" -ForegroundColor Green
Write-Host "Backup location: $BackupDestination" -ForegroundColor Green

# Create the backup destination folder if it doesn't exist
if (-not (Test-Path -Path $BackupDestination)) {
    New-Item -ItemType Directory -Path $BackupDestination | Out-Null
    Write-Host "Created backup destination folder: $BackupDestination" -ForegroundColor Green
}
else {
    # if the folder already exists, append a number to the end of the folder name to make it unique (e.g., "Backup-2024-06-23-1", "Backup-2024-06-23-2", etc.)
    Write-Host "Backup destination folder already exists: $BackupDestination" -ForegroundColor Yellow
    $i = 1
    while (Test-Path -Path "$BackupDestination-$i") {
        $i++
    }
    $BackupDestination = "$BackupDestination-$i"
    # Create the backup destination folder with the unique name
    New-Item -ItemType Directory -Path $BackupDestination | Out-Null
    Write-Host "Created backup destination folder: $BackupDestination" -ForegroundColor Green
}

$subFolders = @("Desktop", "Documents", "Pictures", "Downloads", "Videos", "Music")
foreach ($folder in $subFolders) {
    $subFolderPath = Join-Path -Path $BackupDestination -ChildPath $folder
    if (-not (Test-Path -Path $subFolderPath)) {
        New-Item -ItemType Directory -Path $subFolderPath | Out-Null
        Write-Host "Created subfolder: $subFolderPath" -ForegroundColor Green
    }
    else {
        Write-Host "Subfolder already exists: $subFolderPath" -ForegroundColor Yellow
    }
}
Write-Host ""
Write-Host "Starting backup of $UserProfilePath to $BackupDestination..." -ForegroundColor Green

# create robcopy commands for each folder, copy all contents of each folder into the corresponding destination folder without copying the folder itself
$robocopyCommands = @()
$i = 1
foreach ($folder in $subFolders) {
    $sourcePath = Join-Path -Path $UserProfilePath -ChildPath $folder
    $destinationPath = Join-Path -Path $BackupDestination -ChildPath $folder
    $robocopyCommands += "robocopy `"$sourcePath`" `"$destinationPath`" /E /COPYALL /R:3 /W:5 /LOG+:`"$BackupDestination\backup-$i.log`""
    $i++
}


$jobs = @()
foreach ($command in $robocopyCommands) {
    $folderName = ($command -split "`"")[1] -replace "C:\\Users\\$Username\\", "" -replace "\\\*", ""
    Write-Host "Starting backup of $folderName..." -ForegroundColor Green

    $jobs += Start-Job -ScriptBlock { Invoke-Expression -Command $using:command }

}

Write-Host "All backup jobs started. Waiting for completion..." -ForegroundColor Green
Write-Host ""

$jobs | Wait-Job | Out-Null

Write-Host "Backup completed successfully!" -ForegroundColor Green
[console]::beep(1000, 1000)