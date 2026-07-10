##
# Get-Procs.ps1
# Description: This script retrieves the list of running processes from a specified remote computer and displays them in a formatted table.
# Parameters:
#    -TargetComputer: The name of the remote computer to retrieve the process list from
# Example usage:
#    .\Get-Procs.ps1 -TargetComputer "RemotePC"
##

[CmdletBinding()]
param (
    [Parameter(Mandatory = $true)]
    [string]$TargetComputer,

    [Parameter(Mandatory = $false)]
    [string]$IncludeHashes,

    [Parameter(Mandatory = $false)]
    [string]$UseVirusTotal
)

function Import-Env {
    param(
        [string]$Path = "$PSScriptRoot\.env"
    )

    if (!(Test-Path $Path)) {
        throw ".env file not found at $Path"
    }

    Get-Content $Path | ForEach-Object {
        $line = $_.Trim()
        
        # Skip empty lines and comments
        if ([string]::IsNullOrEmpty($line) -or $line.StartsWith("#")) { return }

        # Split on the first '=' only
        $parts = $line -split '=', 2
        if ($parts.Count -eq 2) {
            $key = $parts[0].Trim()
            $value = $parts[1].Trim()

            # Remove surrounding quotes if present
            if (($value.StartsWith('"') -and $value.EndsWith('"')) -or 
                ($value.StartsWith("'") -and $value.EndsWith("'"))) {
                $value = $value.Substring(1, $value.Length - 2)
            }

            # Set the environment variable for the current process
            Set-Item -Path "env:$key" -Value $value
        }
    }
}

Write-Host ""
Write-Host "Retrieving process list from $TargetComputer..." -ForegroundColor Green
try {
    $processes = Get-WmiObject -Class Win32_Process -ComputerName $TargetComputer
    if ($processes) {
        Write-Host "Process list retrieved successfully!" -ForegroundColor Green
        Write-Host ""
        if ($IncludeHashes -eq "-h" -or $IncludeHashes -eq "--hashes" -or $IncludeHashes -eq "--hash") {
            Write-Host "Computing hashes for process executable paths, this could take a moment..." -ForegroundColor Green
            # compute the hashes of each process's executable path for verification
            foreach ($process in $processes) {
                if ($process.ExecutablePath) {
                    $uncPath = $process.ExecutablePath -replace "^[cC]:", "C$"
                    $uncPath = "\\$TargetComputer\$uncPath"
                    try {
                        $hash = Get-FileHash -Path $uncPath -Algorithm SHA256
                        $process | Add-Member -MemberType NoteProperty -Name "SHA256Hash" -Value $hash.Hash
                    }
                    catch {
                        $process | Add-Member -MemberType NoteProperty -Name "SHA256Hash" -Value "N/A"
                    }
                }
                else {
                    $process | Add-Member -MemberType NoteProperty -Name "SHA256Hash" -Value "N/A"
                }
            }

            $processes | Select-Object Name, SHA256Hash, ProcessId, CommandLine | Format-Table -AutoSize
            if ($UseVirusTotal -eq '--vt') {
                # send hashes to vt via api call
                Write-host "Cross referencing hashes against Virust Total database..."
                Import-Module "$PSScriptRoot\..\Modules\VirusTotalAnalyzer\VirusTotalAnalyzer.psm1" -Force
                Import-Env
                $apiKey = $env:VT_API_KEY
                
                $hashes = $processes | Select-Object SHA256Hash | Format-Table -AutoSize
                write-host "Sending hashes to VT ..."
                foreach ($hash in $hashes) {
                    $response = Get-VirusReport -ApiKey $apiKey -Hash $hash
                    write-host $response
                }
                write-host "done"
            }
        }
        else {
            $processes | Select-Object Name, ProcessId, CommandLine | Format-Table -AutoSize
        }

        Write-Host "Done!" -ForegroundColor Green
        Write-Host ""
    }
    else {
        Write-Host "No processes found on $TargetComputer"
    }
}
catch {
    Write-Host "Failed to retrieve process list from $TargetComputer : $($_.Exception.Message)" -ForegroundColor Red
}
