##
# Get-Software.ps1
# Description: This script retrieves a list of installed software on the target machine. It uses the Get-WmiObject cmdlet to query the Win32_Product class, which contains information about installed software. The script then formats and displays the list of software in a readable format.
# Parameters:
#    -TargetComputer: The name of the computer to query for installed software (required)
# Example usage:
#    .\Get-Software.ps1 -TargetComputer "RemotePC"
##

[CmdletBinding()]
param (
    [Parameter(Mandatory=$true)]
    [string]$TargetComputer
)

Write-Host "Attempting to retrieve installed software from $TargetComputer..." -ForegroundColor Green

try {
    $softwareList = Get-WmiObject -Class Win32_Product -ComputerName $TargetComputer -ErrorAction Stop
    if ($softwareList) {
        Write-Host "Installed software on $TargetComputer :" -ForegroundColor Green
        foreach ($software in $softwareList) {
            Write-Host "$($software.Name) - Version: $($software.Version)" -ForegroundColor Cyan
        }
    }
    else {
        Write-Host "No installed software found on $TargetComputer." -ForegroundColor Yellow
    }
}
catch {
    Write-Error "An error occurred while retrieving the software list: $_"
}
