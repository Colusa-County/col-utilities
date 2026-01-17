# @name         Backup Script
# @author       Henry Graves
# @date         6/23/2025
# @description  Backs up a users data from their current PC to their U: drive on
#               the network. At the moment it is a very dumb script, it blindly
#               grabs everything in the users" Desktop, Documents, Pictures and
#               Downloads folders. This has been done to ensure nothing is missed.
#               To restore the backup to their new PC run the corresponding restore
#               script while on their new PC.
# @usage        Simply run the script.

$NetworkDrive = "U:"
$BackupDate = Get-Date -Format "MM-dd-yyyy"
$BackupRoot = Join-Path $NetworkDrive "PC Backup $BackupDate"

$UserProfile = $env:USERPROFILE
$SourceFolders = @(
    "$UserProfile\Documents",
    "$UserProfile\Desktop",
    "$UserProfile\Pictures"
    #"$UserProfile\Downloads"
)

function Test-NetworkDrive {
    param($DrivePath)
    if (!(Test-Path $DrivePath)) {
        Write-Error "Network drive $DrivePath is not accessible."
        exit 1
    }
}

function Create-Backup {
    param($Source, $Destination)

    try {
        Write-Host "Backing up $Source to $Destination ..."

        if (!(Test-Path $Destination)) {
            New-Item -ItemType Directory -Path $Destination -Force | Out-Null
        }

        $Files = Get-ChildItem -Path $Source -Recurse -File
        $TotalFiles = $Files.Count
        $CurrentFile = 0

        foreach ($File in $Files) {
            $CurrentFile++
            $PercentComplete = [math]::Round(($CurrentFile / $TotalFiles) * 100)
            Write-Progress -Activity "Copying files from $Source" -Status "Processing file $CurrentFile of $TotalFiles" -PercentComplete $PercentComplete
            $RelativePath = $File.FullName.Substring($Source.Length)
            $DestPath = Join-Path $Destination $RelativePath

            $DestDir = Split-Path $DestPath -Parent
            if (!(Test-Path $DestDir)) {
                New-Item -ItemType Directory -Path $DestDir -Force | Out-Null
            }

            # Copy-Item -Path $File.FullName -Destination $DestPath -Force -ErrorAction Stop
            Robocopy.exe $File.DirectoryName $DestDir $File.Name /COPYALL /R:3 /W:5 | Out-Null
        }

        Write-Host "Backup of $Source completed successfully."

    } catch {
        Write-Error "Error backing up $Source : $($_.Exception.Message)"
    }
}

try {
    Test-NetworkDrive $NetworkDrive
    
    if (!(Test-Path $BackupRoot)) {
        New-Item -ItemType Directory -Path $BackupRoot -Force | Out-Null
    }

    foreach ($Folder in $SourceFolders) {
        if (Test-Path $Folder) {
            $FolderName = Split-Path $Folder -Leaf
            $DestFolder = Join-Path $BackupRoot $FolderName 
            Create-Backup -Source $Folder -Destination $DestFolder
        } else {
            Write-Warning "Source folder $Folder does not exist. Skipping ..."
        }
    }

    Write-Host "Backup completed successfully to $BackupRoot"
} catch {
    Write-Error "Backup process failed: $($_.Exception.Message)"
    exit 1
} finally {
    Write-Progress -Activity "Copying Files" -Completed
}