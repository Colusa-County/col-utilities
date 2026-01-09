
# @name         Restore Script
# @author       Henry Graves
# @date         6/23/2025
# @description  Restores a users data from their U: network drive after
#               a backup was created using the corresponding backup script.
#               Currently this script only works properly if used on the same
#               day as the backup script as it uses datestamps to target the
#               correct backup folder on the U: drive. This may be improved
#               in the future.
# @usage        Simply run the script.

$NetworkDrive = "U:"
$BackupDate = Get-Date -Format "MM-dd-yyyy"
$BackupRoot = Join-Path $NetworkDrive "PC Backup $BackupDate"

$UserProfile = $env:USERPROFILE
$DestinationFolders = @{
    "Documents" = "$UserProfile\Documents"
    "Desktop" = "$UserProfile\Desktop"
    "Pictures" = "$UserProfile\Pictures"
    "Downloads" = "$UserProfile\Downloads"
}

function Test-BackupSource {
    param($BackupPath)
    if (!(Test-Path $BackupPath)) {
        Write-Error "Backup folder $BackupPath does not exist or is not accessible."
        exit 1
    }
}

function Restore-Folder {
    param($Source, $Destination)
    try {
        Write-Host "Restoring $Source to $Destination ..."
        if (!(Test-Path $Destination)) {
            New-Item -ItemType Directory -Path $Destination -Force | Out-Null
        }
        $Files = Get-ChildItem -Path $Source -Recurse -File
        $TotalFiles = $Files.Count
        $CurrentFile = 0
        foreach ($File in $Files) {
            $CurrentFile++
            $PercentComplete = [math]::Round(($CurrentFile / $TotalFiles) * 100)
            Write-Progress -Activity "Restoring files to $Destination" -Status "Processing file $CurrentFile of $TotalFiles" -PercentComplete $PercentComplete
            $RelativePath = $File.FullName.Substring($Source.Length)
            $DestPath = Join-Path $Destination $RelativePath

            $DestDir = Split-Path $DestPath -Parent
            if (!(Test-Path $DestDir)) {
                New-Item -ItemType Directory -Path $DestDir -Force | Out-Null
            }
            Copy-Item -Path $File.FullName -Destination $DestPath -Force -ErrorAction Stop
        }
        
        Write-Host "Restore of $Source to $Destination completed successfully!"
    } catch {
        Write-Error "Error restroing $Source to $Destination : $($_.Exception.Message)"
    }
}

try {
    Test-BackupSource $BackupRoot

    foreach ($FolderName in $DestinationFolders.Keys) {
        $SourceFolder = Join-Path $BackupRoot $FolderName
        $DestFolder = $DestinationFolders[$FolderName]

        if (Test-Path $SourceFolder) {
            Restore-Folder -Source $SourceFolder -Destination $DestFolder
        } else {
            Write-Warning "Backuyp Folder $SourceFolder does not erxist. Skipping ..."
        }

    }
    Write-Host "Restor completeed successfully from $BackupRoot"
} catch {
    Write-Error "Restore process failed: $($_Exception.Message)"
    exit 1
} finally {
    Write-Progress -Activity "Restoring files" -Completed
}