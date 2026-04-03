##
# Get-OSTFiles.ps1
# Description: This script will get the OST files for the specified computer and report their sizes
# Parameters:
#   -ComputerName: The name of the computer to get OST file information for (defaults to the local computer if not specified)
##

[CmdletBinding()]
param(
    [Parameter(Mandatory=$false)]
    [string[]] $ComputerName = $env:COMPUTERNAME,

    [Parameter(Mandatory=$false)]
    [string] $clear
)

# check for administrative privileges
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Error "You do not have administrative privileges. Please run this script as an administrator and try again."
    exit
}

$files = @()
foreach ($computer in $ComputerName)
{
    Write-Host "Getting OST file information for computer: $computer" -ForegroundColor Green

    # check if computer is reachable
    if (-not (Test-Connection -ComputerName $computer -Count 1 -ErrorAction SilentlyContinue)) {
        Write-Error "The computer '$computer' is not reachable. Please ensure the computer name is correct and try again."
        exit
    }

    # get list of users on the specified computer
    $users = Get-WmiObject -Class Win32_UserProfile -ComputerName $computer | Select-Object -ExpandProperty LocalPath

    Write-Host "Checking OST files for users on $computer..." -ForegroundColor Green
    Write-Host ""
    $ThisPCFiles = @();
    foreach ($user in $users) {
        
        $splitUserName = $user.Split('\')[-1]

        $ostPath = "\\$computer\C$\Users\$splitUserName\AppData\Local\Microsoft\Outlook\"

        # write-host $ostPath
        
        if (Test-Path -Path $ostPath) {
            $ostFiles = Get-ChildItem -Path $ostPath -Filter *.ost -ErrorAction SilentlyContinue
            foreach ($ostFile in $ostFiles) {
                Write-Host "Found OST file: " -NoNewline
                Write-Host "$($ostFile.FullName.Split('\')[-1]) " -NoNewline -ForegroundColor Yellow
                Write-Host "with size: " -NoNewline
                Write-Host "$([Math]::Round($ostFile.Length / 1GB, 2))" -NoNewline -ForegroundColor Red
                Write-Host " GB" -ForegroundColor Cyan
                # Write-Host ""
                $files += [PSCustomObject]@{
                    Computer = $computer
                    User = $splitUserName
                    FilePath = $ostFile.FullName
                    SizeMB = [Math]::Round($ostFile.Length / 1MB, 2)
                    TotalSizeGB = 0
                }
                $ThisPCFiles += [PSCustomObject]@{
                    Computer = $computer
                    User = $splitUserName
                    FilePath = $ostFile.FullName
                    SizeMB = [Math]::Round($ostFile.Length / 1MB, 2)
                    TotalSizeGB = 0
                }
            }
        }
        
    }

    # total data size of all OST files found in GB (per computer)
    $totalSizeGB = [Math]::Round(($ThisPCFiles | Measure-Object -Property SizeMB -Sum).Sum / 1024, 2)
    Write-Host "Total size of all OST files found: $totalSizeGB GB" -ForegroundColor Green
    Write-Host ""
    $ThisPCFiles = $null
}
Write-Host ""

# at this point $files should contain ALL files from all computers scanned



# add totalsizeGB to each file object
foreach ($file in $files) {
    $file.TotalSizeGB = [Math]::Round($file.SizeMB / 1024, 2)
}

if ($clear -eq "--clear" -or $clear -eq "-c") {
    Write-Host "Are you sure you want to delete all OST files found? This action cannot be undone." -ForegroundColor Red
    $userInput = Read-Host "Type 'yes' to confirm"
    if ($userInput -ne "yes") {
        Write-Host "Aborting OST file deletion." -ForegroundColor Yellow
        exit
    }
    Write-Host "Clearing OST files..." -ForegroundColor Yellow
    foreach ($file in $files) {
        try {
            Remove-Item -Path $file.FilePath -Force -ErrorAction SilentlyContinue
            Write-Host "Deleted OST file: $($file.FilePath)" -ForegroundColor Green
        }
        catch {
            Write-Warning "Failed to delete OST file: $($file.FilePath). Error: $_"
        }
    }
    
    return
}

return $files