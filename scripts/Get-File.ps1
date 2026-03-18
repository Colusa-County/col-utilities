##
# Grab-File.ps1
# Description: Grabs a file from a remote computer and saves it locally
# Parameters:
#    -TargetComputer: The name of the remote computer to grab the file from
#    -RemoteFilePath: The full path to the file on the remote computer (e.g., "\\RemotePC\C$\Path\To\File.txt")
#    -LocalSavePath: The full path where the file should be saved locally (e.g., "C:\Local\Path\File.txt")
# Example usage:
#    .\Grab-File.ps1 -TargetComputer "RemotePC" -RemoteFilePath "\\RemotePC\C$\Path\To\File.txt" -LocalSavePath "C:\Local\Path\File.txt"
##

[CmdletBinding()]
param (
    [Parameter(Mandatory = $true)]
    [string]$TargetComputer,

    [Parameter(Mandatory = $true)]
    [string]$RemoteFilePath,

    [Parameter(Mandatory = $true)]
    [string]$LocalSavePath
)

# convert the "c:" in remote file path to "C$" for UNC path format
$RemoteFilePath = $RemoteFilePath -replace "^[cC]:", "C$"

#append target computer name to remote file path
$RemoteFilePath = "\\$TargetComputer\$RemoteFilePath"

Write-Host ""
Write-Host ""


Write-Host "Attempting to copy file from $TargetComputer..."
try {
    if (Test-Path $RemoteFilePath -ErrorAction Stop) {
        Write-Host "File found!" -ForegroundColor Green
        Copy-Item -Path $RemoteFilePath -Destination $LocalSavePath -Force
        Write-Host "File successfully copied and saved to: $LocalSavePath" -ForegroundColor Green
        Write-Host ""
        
        # extract the filename from the remote file path for display purposes
        $fileName = Split-Path -Path $RemoteFilePath -Leaf

        # compute the hash of the copied file for verification
        $hash = Get-FileHash -Path "./$fileName" -Algorithm SHA256
        Write-Host "SHA256 Hash of copied file: $($hash.Hash)" -ForegroundColor Cyan
        $md5Hash = Get-FileHash -Path "./$fileName" -Algorithm MD5
        Write-Host "MD5 Hash of copied file:    $($md5Hash.Hash)" -ForegroundColor Cyan
        $sha1Hash = Get-FileHash -Path "./$fileName" -Algorithm SHA1
        Write-Host "SHA1 Hash of copied file:   $($sha1Hash.Hash)" -ForegroundColor Cyan
        Write-Host ""
    }
    else {
        Write-Verbose "File not found: $RemoteFilePath"
        Write-Output "File not found: $RemoteFilePath"
    }
}
catch {
    Write-Output "Invalid path or cannot access $RemoteFilePath : $($_.Exception.Message)"
    Write-Output "Failed to grab file: $RemoteFilePath"
}

