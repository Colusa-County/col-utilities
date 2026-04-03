##
# Report-Storage.ps1
# Description: This script will report back the disk space information for specified machines
# the amount of space taken up by OST files on the machines.
# Parameters:
#   -ComputerNames: An array of computer names to get disk space information for (defaults to the local computer if not specified)
##

[CmdletBinding()]
param(
    [Parameter(Mandatory=$false)]
    [string[]] $ComputerNames = $env:COMPUTERNAME
)

# establish path to scripts folder
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition

# check for admin privs
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Error "You do not have administrative privileges. Please run this script as an administrator and try again."
    exit
}

$ComputerStats = @()
$diskSpaceInfo = @()
$ostInfo = @()

foreach ($computer in $ComputerNames) {
   
    # check if computer is online first
    if (-not (Test-Connection -ComputerName $computer -Count 1 -Quiet)) {
        Write-Warning "Computer $computer is not reachable. Skipping..."
        Write-Host ""
        continue
    }

    $diskSpaceInfo += & $scriptDir\Get-DiskSpace.ps1 -ComputerName $computer

    # returns ost info for each user on target machine
    $ostInfo += & $scriptDir\Get-OSTFiles.ps1 -ComputerName $computer

    # loop through ostInfo and sum up total size of OST files
    $totalOSTGBSize = 0
    foreach ($ost in $ostInfo)
    {
        $totalOSTGBSize += [Math]::Round($ost.SizeMB / 1024, 2)
    }

    # add diskspace info and ost total size together in a new object

    $ComputerStats += @{
        Computer = $diskSpaceInfo.Computer
        TotalSizeGB = $diskSpaceInfo.TotalSizeGB
        UsedSpaceGB = $diskSpaceInfo.UsedSpaceGB
        FreeSpaceGB = $diskSpaceInfo.FreeSpaceGB
        OSTSizeGB = $totalOSTGBSize
    }
    
    # todo: add temp file collection from appdata and programdata to this report as well

    $diskSpaceInfo = $null
    $ostInfo = $null
    $totalOSTGBSize = 0

    # Write-Host "------------------------------" -ForegroundColor Cyan
    Write-Host "Finished gathering information for computer $computer" -ForegroundColor Yellow
    Write-Host "Starting next computer..." -ForegroundColor Yellow
    # Write-Host "------------------------------" -ForegroundColor Cyan
    Write-Host ""
}

Write-Host "-------------------------------------------------------" -ForegroundColor Green
Write-Host "Disk space and OST file report for specified computers:" -ForegroundColor Green
Write-Host "-------------------------------------------------------" -ForegroundColor Green

# output results
$i = 1
foreach ($stat in $ComputerStats) {
    Write-Host "Computer ${i}: $($stat.Computer)" -ForegroundColor Cyan
    Write-Host "Total Disk Size (GB): $($stat.TotalSizeGB)" -ForegroundColor Green
    Write-Host "Used Disk Space (GB): $($stat.UsedSpaceGB)" -ForegroundColor Yellow
    Write-Host "Free Disk Space (GB): $($stat.FreeSpaceGB)" -ForegroundColor Red
    Write-Host "OST File Size (GB): $($stat.OSTSizeGB)" -ForegroundColor Magenta
    Write-Host ""
    $i++
}

