##
# Get-LastUsedComputer.ps1
# Description: This script will get the last used computer for the supplied user
# Parameters:
#   -username: The username of the user to get last used computer for
##

[CmdletBinding()]
param (
    [string]$username
)

# check for AD module
if (-not (Get-Module -ListAvailable -Name ActiveDirectory)) {
    Write-Error "The Active Directory module is not installed. Please install it and try again."
    exit
}

# check for administrative privileges
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Error "You do not have administrative privileges. Please run this script as an administrator and try again."
    exit
}

# get the last used computer by the user
$lastUsedComputer = Get-ADUser -Identity $username -Properties lastLogonComputer | Select-Object -ExpandProperty lastLogonComputer



Write-Host "Last used computer for user $username-> " -ForegroundColor Green
Write-Output $lastUsedComputer

Write-Host ""
Write-Host "Checking if $lastUsedComputer is online..." -ForegroundColor Green

# check if this PC is online
if (Test-Connection -ComputerName $lastUsedComputer -Count 1 -ErrorAction SilentlyContinue) {
    Write-Host "$lastUsedComputer is online." -ForegroundColor Green
}
else {
    Write-Host "$lastUsedComputer is offline or unreachable." -ForegroundColor Red
}