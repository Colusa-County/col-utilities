##
# Backup.ps1
# Description: This script performs a backup of the specified user's Desktop, Documents, Pictures, Downloads, Videos, and Music folders into a zip archive
#              and saves it to a specified backup location. The backup file is named using the format "Backup-<Username>-<Date>-<Time>.zip" to ensure uniqueness and easy identification.
#    -Username: The username of the profile to back up (e.g., "jdoe")
# Example usage:
#    .\Backup.ps1 -Username "jdoe" -BackupLocation "C:\Backups"
##

[CmdletBinding()]
param (
    [Parameter(Mandatory = $true)]
    [string]$Username,

    [Parameter(Mandatory = $true)]
    [string]$BackupLocation

)

# create an array that holds icons for a spinner animation to indicate that the backup is in progress
$spinnerIcons = @("⣾", "⣷", "⣯", "⣟", "⣻", "⣽", "⣾", "⣷", "⣯", "⣟", "⣻", "⣽")
$spinnerIndex = 0


$UserProfile = "C:\Users\$Username"
$SourceFolders = @(
    "$UserProfile\Documents",
    "$UserProfile\Desktop",
    "$UserProfile\Pictures",
    "$UserProfile\Downloads",
    "$UserProfile\Videos",
    "$UserProfile\Music"
)

$DateTime = Get-Date -Format "yyyy-MM-dd-HH-mm-ss"
$BackupFileName = "PC-Backup-$DateTime"
$BackupFilePath = Join-Path $BackupLocation $BackupFileName

# if the backup location doesn't exist, create it
if (!(Test-Path $BackupFilePath)) {
    New-Item -ItemType Directory -Path $BackupFilePath -Force
}

# create corresponding subfolders in the backup location for each source folder to preserve the directory structure
foreach ($SourceFolder in $SourceFolders) {
    $FolderName = Split-Path -Path $SourceFolder -Leaf
    $DestinationFolder = Join-Path $BackupFilePath $FolderName
    New-Item -ItemType Directory -Path $DestinationFolder -Force
    # Copy-Item -Path $SourceFolder\* -Destination $DestinationFolder -Recurse -Force
}

# for each sub folder, spawn a job to copy the files in parallel to speed up the backup process
foreach ($SourceFolder in $SourceFolders) {
    $FolderName = Split-Path -Path $SourceFolder -Leaf
    $DestinationFolder = Join-Path $BackupFilePath $FolderName
    Start-Job -ScriptBlock {
        param($Source, $Destination)
        Copy-Item -Path "$Source\*" -Destination $Destination -Recurse -Force
    } -ArgumentList $SourceFolder, $DestinationFolder
}

Clear-Host
Write-Host "Backup jobs running..." -ForegroundColor Green
Write-Host ""

# write host for each subfolder being backed up
foreach ($SourceFolder in $SourceFolders) {
    $FolderName = Split-Path -Path $SourceFolder -Leaf
    Write-Host "Backing up $SourceFolder to         $BackupFilePath\$FolderName" -ForegroundColor Green
}

Write-Host ""

# for each job that was spawned, wait for it to complete and display a spinner animation in the console to indicate that the backup is in progress
while (Get-Job -State "Running") {
    Write-Host -NoNewline ("Backing up files... " + $spinnerIcons[$spinnerIndex] + " ") -ForegroundColor Cyan
    Start-Sleep -Seconds 0.1
    Write-Host -NoNewline "`r" # carriage return to overwrite the previous line in the console
    $spinnerIndex = ($spinnerIndex + 1) % $spinnerIcons.Length
}

Clear-Host
Write-Host "Backup completed successfully! Backup saved to: $BackupFilePath" -ForegroundColor Green
