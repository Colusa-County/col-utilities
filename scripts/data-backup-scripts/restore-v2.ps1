

# Test network path
function Test-DrivePath {
    param($DrivePath)
    if (!(Test-Path $DrivePath)) {
        Write-Error "Network drive $DrivePath is not accessible."
        exit 1
    }
    else {
        Write-Host "Network drive $DrivePath is accessible. Continuing..."
        Write-Host ""
    }
}

function Find-Backups {
    param($BackupRoot) 
    $backupFolders = Get-ChildItem -Path $BackupRoot -Directory | Where-Object { $_.Name -like "PC Backup *" }
    return $backupFolders
}

function Select-Backup {
    param($BackupFolders)
    Write-Host "Available backups:"
    for ($i = 0; $i -lt $BackupFolders.Count; $i++) {
        Write-Host "[$i] $($BackupFolders[$i].Name)"
    }

    $selection = Read-Host "Enter the number of the backup you want to restore"
    if ($selection -ge 0 -and $selection -lt $BackupFolders.Count) {
        return $BackupFolders[$selection]
    }
    else {
        Write-Error "Invalid selection. Exiting."
        exit 1
    }
}

Clear-Host

$NetworkDrive = "U"
$UserProfile = $env:USERPROFILE

# Test network drive access
Test-DrivePath $NetworkDrive

# search for backup folders on users U drive.
$backups = Find-Backups $NetworkDrive

# list possible backups to restore from
# allow selection from list
$backup = Select-Backup $backups


# copy all items to respective folders on local machine (documents, desktop, pictures, downloads, etc)
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

