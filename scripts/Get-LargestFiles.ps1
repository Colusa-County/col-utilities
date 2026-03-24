##
# Get-LargestFiles.ps1
# Description: Scans the C$ share of a specified computer for the largest files and exports the list to a CSV file.
# Parameters:
#    -ComputerName: The name of the target computer to scan for large files 
#
# Usage: .\Get-TopFiles.ps1 -ComputerName "TargetComputerName"
##

[CmdletBinding()]
param(
    [Parameter(Mandatory=$true, Position=0, ValueFromRemainingArguments=$true)]
    [string[]] $ComputerName = $env:COMPUTERNAME,

    [Parameter(Mandatory=$false)]
    [string] $full
)

$computersScanned = @()

Clear-Host
# prompt user for admin rights
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator"))
{
    Write-Warning "This script must be run as an Administrator. Please restart PowerShell as Administrator and try again."
    exit 1
}

Write-Host "Computers to scan: $ComputerName"
Write-Host ""

foreach ($computer in $ComputerName)
{

    # check if computer is online first
    if (-not (Test-Connection -ComputerName $computer -Count 1 -Quiet))
    {
        Write-Warning "Computer $computer is not reachable. Skipping..."
        Write-Host ""
        continue
    }

    $allFiles = @()

    if ($full -eq "--full" -or $full -eq "-f") {
        Write-Host "Performing full scan of $computer. This may take some time..." -ForegroundColor Yellow
        $uncRoot = "\\$computer\C$"
    }
    else {
        Write-Host "Performing quick scan of $computer (only scanning user directories). Use --full switch for a complete scan." -ForegroundColor Yellow
        $uncRoot = "\\$computer\C$\Users"
        
    }

    Write-Host "Scanning drive $uncRoot for files..."
    # exit 1

    Get-ChildItem -Path $uncRoot -Recurse -File -ErrorAction SilentlyContinue |
    ForEach-Object {
        #skip the /windows directory to save time
        if ($_.FullName -like "*\windows\*")
        {
            return
        }

        # write to console the current object being processed
        $currentObject = [pscustomobject]@{
            FullName = $_.FullName
            Length = $_.Length
        }
        # write progress to console
        Write-Progress -Activity "Scanning files on $computer" -Status "Processing file: $($currentObject.FullName)" -PercentComplete 0 

        # Write-Host "Processing file: $($currentObject.FullName) - Size: $($currentObject.Length) bytes"

        $allFiles += $currentObject
    }

    $topFiles = $allFiles | Sort-Object -Property Length -Descending

    $topFiles | ForEach-Object {
        # if any file is over 1GB in size, write to console
        if ($_.Length -gt 1GB)
        {
            $sizeInGB = [math]::Round($_.Length / 1GB, 2)
            Write-Host "Large file found: $($_.FullName) - Size: $sizeInGB GB" -ForegroundColor Red
        }
    }

    # output entire $topFiles list from largest file to smallest along with their sizes in MB with clean formatting
    # $topFiles | ForEach-Object {
    #     $sizeInMB = [math]::Round($_.Length / 1MB, 2)
    #     Write-Host "Size: $sizeInMB MB -- File: $($_.FullName)"
    # }

    

    # get the date in MM-dd-yyyy format
    $dateString = Get-Date -Format "MM-dd-yyyy"

    #export this list to a csv file and open it in excel
    $exportPath = "C:\Users\$env:USERNAME\Documents\$computer-files-$dateString.csv"
    $topFiles | Select-Object FullName, @{Name="SizeInMB";Expression={[math]::Round($_.Length / 1MB, 2)}} | Export-Csv -Path $exportPath -NoTypeInformation -Encoding UTF8
    
    $computersScanned += $exportPath

    Write-Host ""
    Write-Host "Exported largest files list to $exportPath" -ForegroundColor Green
    Write-Host "---------------------------------------------------------------"
    # output total disk space used and remaining on C: drive of target computer, add to csv file
    $disk = Get-WmiObject -Class Win32_LogicalDisk -ComputerName $computer -Filter "DeviceID='C:'"
    $totalSizeGB = [math]::Round($disk.Size / 1GB, 2)
    $freeSpaceGB = [math]::Round($disk.FreeSpace / 1GB, 2)
    $usedSpaceGB = [math]::Round($totalSizeGB - $freeSpaceGB, 2)
    Write-Host "C: Drive on $computer - Total Size: $totalSizeGB GB, Used Space: $usedSpaceGB GB, Free Space: $freeSpaceGB GB"
    Write-Host "---------------------------------------------------------------"

    
    Write-Host ""
}

Write-Host "Scan complete for all specified computers."
Write-Host "Files exported to the following locations:"
foreach ($path in $computersScanned)
{
    # output each path with green text
    Write-Host $path -ForegroundColor Green
}


