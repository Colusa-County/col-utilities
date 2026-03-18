##
# Confirm-Executable.ps1
# Description: Confirms the presence of a specific executable on a remote computer and returns it's hash
# Parameters:
#    -ExecutablePath: The full path to the executable to confirm (e.g., "\\RemotePC\C$\Program Files\App\app.exe")
#    -TargetComputer: The name of the remote computer to check
# Example usage:
#    .\Confirm-Executable.ps1 -TargetComputer "RemotePC" -ExecutablePath "\\RemotePC\C$\Program Files\App\app.exe"
##

[CmdletBinding()]
param (
    [Parameter(Mandatory = $true)]
    [string]$TargetComputer,

    [Parameter(Mandatory = $true)]
    [string]$ExecutablePath
)

# convert the "c:" in executable path to "C$" for UNC path format
$ExecutablePath = $ExecutablePath -replace "^[cC]:", "C$"
#append target computer name to executable path
$ExecutablePath = "\\$TargetComputer\$ExecutablePath"

# space out the output for readability
Write-Output ""

Write-Output "Confirming presence of file ..."
try {
    if (Test-Path $ExecutablePath -ErrorAction Stop) {
        Write-Host "Executable found: $ExecutablePath" -ForegroundColor Green
        
        # make the output pretty by adding a separator line
        Write-Output ""

        # Calculate the hash of the executable
        $hash = Get-FileHash -Path $ExecutablePath -Algorithm SHA256
        # Write-Output "Executable confirmed: $ExecutablePath"
        # format output to line up the hash values and make them cyan for visibility
        Write-Host "SHA256 Hash:    $($hash.Hash)" -ForegroundColor Cyan

        # compute other hashes of executable (MD5, SHA1) and output them as well
        $md5Hash = Get-FileHash -Path $ExecutablePath -Algorithm MD5
        Write-Host "MD5 Hash:       $($md5Hash.Hash)" -ForegroundColor Cyan

        $sha1Hash = Get-FileHash -Path $ExecutablePath -Algorithm SHA1
        Write-Host "SHA1 Hash:      $($sha1Hash.Hash)" -ForegroundColor Cyan

        Write-Output ""

        Write-Output "Hashes Computed"
        Write-Output ""


    }
    else {
        Write-Verbose "Executable not found: $ExecutablePath"
        Write-Output "Executable not found: $ExecutablePath"
    }
}
catch {
    Write-Output "Cannot access $ExecutablePath : $($_.Exception.Message)"
    Write-Output "Executable not found: $ExecutablePath"
}