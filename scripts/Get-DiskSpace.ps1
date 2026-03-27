##
# Get-DiskSpace.ps1
# Description: This script will get the disk space information for the specified computer(s)
# Parameters:
#   -ComputerName: An array of computer names to get disk space information for (defaults to the local computer if not specified)
# Example usage:
#   Get-DiskSpace.ps1 -ComputerName Computer1, Computer2
##

[CmdletBinding()]
param(
    [Parameter(Mandatory=$false)]
    [string[]] $ComputerName = $env:COMPUTERNAME
)

# for each computer, get total disk space free and used on the C: drive
foreach ($computer in $ComputerName) {
    Write-Host "Getting disk space information for computer $computer..." -ForegroundColor Green
    
    # check if computer is online first
    if (-not (Test-Connection -ComputerName $computer -Count 1 -Quiet)) {
        Write-Warning "Computer $computer is not reachable. Skipping..."
        Write-Host ""
        continue
    }

    # get disk space information for C: drive
    $disk = Get-WmiObject -Class Win32_LogicalDisk -ComputerName $computer -Filter "DeviceID='C:'"
    $totalSizeGB = [math]::Round($disk.Size / 1GB, 2)
    $freeSpaceGB = [math]::Round($disk.FreeSpace / 1GB, 2)
    $usedSpaceGB = [math]::Round($totalSizeGB - $freeSpaceGB, 2)

    $diskSpace = @{
        ComputerName = $computer
        TotalSizeGB = $totalSizeGB
        UsedSpaceGB = $usedSpaceGB
        FreeSpaceGB = $freeSpaceGB
    }

    Write-Output $diskSpace
    Write-Host ""
}