##
# Confirm-File.ps1
# Description: Confirms the presence of a specific file on a remote computer and returns its hash
# Parameters:
#    -FilePath: The full path to the file to confirm (e.g., "\\RemotePC\C$\Path\To\File.txt")
#    -TargetComputer: The name of the remote computer to check
# Example usage:
#    .\Confirm-File.ps1 -TargetComputer "RemotePC" -FilePath "\\RemotePC\C$\Path\To\File.txt"
##

[CmdletBinding()]
param (
    [Parameter(Mandatory = $true)]
    [string]$TargetComputer,

    [Parameter(Mandatory = $true)]
    [string]$FilePath
)

# convert the "c:" in file path to "C$" for UNC path format
$FilePath = $FilePath -replace "^[cC]:", "C$"
#append target computer name to file path
$FilePath = "\\$TargetComputer\$FilePath"

# space out the output for readability
Write-Output ""

Write-Output "Confirming presence of file ..."
try {
    if (Test-Path $FilePath -ErrorAction Stop) {
        Write-Host "File found: $FilePath" -ForegroundColor Green
        
        # make the output pretty by adding a separator line
        Write-Output ""

        # Calculate the hash of the file
        $hash = Get-FileHash -Path $FilePath -Algorithm SHA256
        # Write-Output "File confirmed: $FilePath"
        # format output to line up the hash values and make them cyan for visibility
        Write-Host "SHA256 Hash:    $($hash.Hash)" -ForegroundColor Cyan

        # compute other hashes of file (MD5, SHA1) and output them as well
        $md5Hash = Get-FileHash -Path $FilePath -Algorithm MD5
        Write-Host "MD5 Hash:       $($md5Hash.Hash)" -ForegroundColor Cyan

        $sha1Hash = Get-FileHash -Path $FilePath -Algorithm SHA1
        Write-Host "SHA1 Hash:      $($sha1Hash.Hash)" -ForegroundColor Cyan

        Write-Output ""

        Write-Output "Hashes Computed"
        Write-Output ""


    }
    else {
        Write-Verbose "File not found: $FilePath"
        Write-Output "File not found: $FilePath"
    }
}
catch {
    Write-Output "Cannot access $FilePath : $($_.Exception.Message)"
    Write-Output "File not found: $FilePath"
}