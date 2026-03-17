##
# Delete-File.ps1
# Description: This script deletes a specified file from a remote Windows 11 computer. It requires administrative privileges on the target computer and the ability to access its file system remotely. Does not use Invoke-Command
# Parameters:
#    -TargetComputer: The name of the remote computer to delete the file from
#    -RemoteFilePath: The full path to the file on the remote computer (e.g., "\\RemotePC\C$\Path\To\File.txt")
# Example usage:
#    .\Delete-File.ps1 -TargetComputer "RemotePC" -RemoteFilePath "\\RemotePC\C$\Path\To\File.txt"
##

[CmdletBinding()]
param (
    [Parameter(Mandatory = $true)]
    [string]$TargetComputer,

    [Parameter(Mandatory = $true)]
    [string]$RemoteFilePath
)

# convert the "c:" in remote file path to "C$" for UNC path format
$RemoteFilePath = $RemoteFilePath -replace "^[cC]:", "C$"

# append target computer name to remote file path
$RemoteFilePath = "\\$TargetComputer\$RemoteFilePath"

Write-Host ""
Write-Host "Attempting to delete file from $TargetComputer..."
try {
    if (Test-Path $RemoteFilePath -ErrorAction Stop) {
        Write-Host "File found! Deleting file: $RemoteFilePath" -ForegroundColor Green
        Remove-Item -Path $RemoteFilePath -Force
        Write-Host "File successfully deleted: $RemoteFilePath" -ForegroundColor Green
    }
    else {
        Write-Host "File not found: $RemoteFilePath"
    }
}
catch {
    Write-Host "Invalid path or cannot access $RemoteFilePath : $($_.Exception.Message)"
}