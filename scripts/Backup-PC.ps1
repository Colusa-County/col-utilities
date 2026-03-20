##
# Backup.ps1
# Description: This script performs a backup of the specified user's Desktop, Documents, Pictures, Downloads, Videos, and Music folders into a zip archive
#              and saves it to a specified backup location. The backup file is named using the format "Backup-<Username>-<Date>-<Time>.zip" to ensure uniqueness and easy identification.
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
$BackupFileName = "Backup-$Username-$DateTime.zip"
$BackupFilePath = Join-Path $BackupLocation $BackupFileName

try {
    Write-Host "Creating backup for user '$Username' at '$BackupFilePath'..." -ForegroundColor Green
    Compress-Archive -Path $SourceFolders -DestinationPath $BackupFilePath -Force
    Write-Host "Backup completed successfully!" -ForegroundColor Green
} catch {
    Write-Error "An error occurred during backup: $($_.Exception.Message)"
}
