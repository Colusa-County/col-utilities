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

Write-Verbose "Confirming presence of '$ExecutablePath' on $TargetComputer ..."
try {
    if (Test-Path $ExecutablePath -ErrorAction Stop) {
        Write-Verbose "Executable found: $ExecutablePath"
        
        # Calculate the hash of the executable
        $hash = Get-FileHash -Path $ExecutablePath -Algorithm SHA256
        Write-Output "Executable confirmed: $ExecutablePath"
        Write-Output "SHA256 Hash: $($hash.Hash)"

        # compute other hashes of executable (MD5, SHA1) and output them as well
        $md5Hash = Get-FileHash -Path $ExecutablePath -Algorithm MD5
        Write-Output "MD5 Hash: $($md5Hash.Hash)"

        $sha1Hash = Get-FileHash -Path $ExecutablePath -Algorithm SHA1
        Write-Output "SHA1 Hash: $($sha1Hash.Hash)"

    }
}
catch {
    Write-Verbose "Cannot access $ExecutablePath : $($_.Exception.Message)"
    Write-Output "Executable not found: $ExecutablePath"
}