##
# Get-OSTFiles.ps1
# Description: This script will get the OST files for the specified computer and report their sizes
# Parameters:
#   -ComputerName: The name of the computer to get OST file information for (defaults to the local computer if not specified)
##

[CmdletBinding()]
param(
    [Parameter(Mandatory=$false)]
    [string] $ComputerName = $env:COMPUTERNAME
)

# check for administrative privileges
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Error "You do not have administrative privileges. Please run this script as an administrator and try again."
    exit
}

Write-Host "Getting OST file information for computer: $ComputerName" -ForegroundColor Green

# get OST file paths for each user on the machine
$users = Get-WmiObject -Class Win32_UserProfile -ComputerName $ComputerName | Where-Object { $_.Special -eq $false } | Select-Object -ExpandProperty LocalPath

Write-Host "Checking OST files for users on $ComputerName..." -ForegroundColor Green
foreach ($user in $users) {
    $ostPath = Join-Path -Path $user -ChildPath "AppData\Local\Microsoft\Outlook\*.ost"
    $ostFiles = Get-ChildItem -Path $ostPath -ErrorAction SilentlyContinue
    
    foreach ($ostFile in $ostFiles) {
        $sizeInGB = [math]::Round($ostFile.Length / 1GB, 2)
        Write-Host "OST file found for user $($user): $($ostFile.FullName) - Size: $sizeInGB GB" -ForegroundColor Green
    }
}