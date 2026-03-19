##
# Backup.ps1
# Description: This script performs a backup of the specified user's profile data to their user network drive. It uses Robocopy to copy the user's profile folder to the specified network location, preserving file attributes and permissions.
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

# add a folder named "Backup-(date)" to the backup location for the user, where (date) is the current date in YYYY-MM-DD format
$CurrentDate = Get-Date -Format "yyyy-MM-dd"

# append "<username>$" to the backup location to create a unique folder for each user's backup (e.g., "U:\Backups\jdoe$")
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
    Write-Host "Backup destination folder already exists: $BackupDestination" -ForegroundColor Yellow
    # if the folder already exists, append a number to the end of the folder name to make it unique (e.g., "Backup-2024-06-23-1", "Backup-2024-06-23-2", etc.)
    $i = 1
    while (Test-Path -Path "$BackupDestination-$i") {
        $i++
    }
    $BackupDestination = "$BackupDestination-$i"
    # Create the backup destination folder with the unique name
    New-Item -ItemType Directory -Path $BackupDestination | Out-Null
    Write-Host "Created backup destination folder: $BackupDestination" -ForegroundColor Green
}

Write-Host "Starting backup of $UserProfilePath to $BackupDestination..." -ForegroundColor Green

# Use Robocopy to perform the backup, exclude appdata, system files, temp files, hidden files, and .DAT files, ignore all files that start with a dot ie: "."
$robocopyCommandUniq = "Robocopy `"$UserProfilePath`" `"$BackupDestination`" /E /COPYALL /R:3 /W:5 /XD `"$UserProfilePath\AppData`" `"$UserProfilePath\AppData\Local`" `"$UserProfilePath\AppData\Roaming`" `"$UserProfilePath\AppData\LocalLow`" `"$UserProfilePath\AppData\Temp`" `"$UserProfilePath\AppData\Temp Files`" `"$UserProfilePath\AppData\Temporary Internet Files`" `"$UserProfilePath\AppData\History`" `"$UserProfilePath\AppData\Cookies`" /XF *.sys *.tmp *.log *.dat /XA:H /XA:S"


# create robocopy command to only copy the Desktop, Documents, Pictures, and Downloads folders from the user profile, excluding everything else
$robocopyCommand = "Robocopy `"$UserProfilePath\Desktop`" `"$BackupDestination\Desktop`" /E /COPYALL /R:3 /W:5"
$robocopyCommand += " && Robocopy `"$UserProfilePath\Documents`" `"$BackupDestination\Documents`" /E /COPYALL /R:3 /W:5"
$robocopyCommand += " && Robocopy `"$UserProfilePath\Pictures`" `"$BackupDestination\Pictures`" /E /COPYALL /R:3 /W:5"
$robocopyCommand += " && Robocopy `"$UserProfilePath\Downloads`" `"$BackupDestination\Downloads`" /E /COPYALL /R:3 /W:5"

# make this multithreaded by running each robocopy command in a separate job and waiting for all jobs to complete before proceeding
$robocopyCommands = @(
    "Robocopy `"$UserProfilePath\Desktop`" `"$BackupDestination\Desktop`" /E /COPYALL /R:3 /W:5",
    "Robocopy `"$UserProfilePath\Documents`" `"$BackupDestination\Documents`" /E /COPYALL /R:3 /W:5",
    "Robocopy `"$UserProfilePath\Pictures`" `"$BackupDestination\Pictures`" /E /COPYALL /R:3 /W:5",
    "Robocopy `"$UserProfilePath\Downloads`" `"$BackupDestination\Downloads`" /E /COPYALL /R:3 /W:5",
    "Robocopy `"$UserProfilePath\Videos`" `"$BackupDestination\Videos`" /E /COPYALL /R:3 /W:5",
    "Robocopy `"$UserProfilePath\Music`" `"$BackupDestination\Videos`" /E /COPYALL /R:3 /W:5"
)
$jobs = @()
foreach ($command in $robocopyCommands) {
    # write host for each job starting, display only the folder being copied (Desktop, Documents, Pictures, or Downloads)
    $folderName = ($command -split "`"")[1] -split "\\" | Select-Object -Last 1
    Write-Host "Starting backup of $folderName..." -ForegroundColor Green

    $jobs += Start-Job -ScriptBlock { Invoke-Expression -Command $using:command }

}

# # write output when a job completes
# Register-ObjectEvent -InputObject $jobs -EventName StateChanged -Action {
#     if ($Event.SourceEventArgs.JobStateInfo.State -eq "Completed") {
#         Write-Host "Backup command completed: $($Event.SourceEventArgs.JobStateInfo.Command)" -ForegroundColor Green
#     }
# }

# Wait for all jobs to complete
# $jobs | Wait-Job | 

Write-Host "Backup completed successfully!" -ForegroundColor Green