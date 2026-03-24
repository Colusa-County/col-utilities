##
# Get-ComputerPassword.ps1
# Description: This script will get the local administrator password for the specified computer using Get-LapsADPassword cmdlet from the LAPS module
# Parameters:
#   -computer: The name of the computer to get the local administrator password for
##

[CmdletBinding()]
param (
    [Parameter(Mandatory=$false)]
    [string] $computer,

    #verbose switch for debugging
    [Parameter(Mandatory=$false)]
    [string] $verbosity
)

# if no computer is specified, get the local administrator password for the current computer
if (-not $computer) {
    $computer = $env:COMPUTERNAME
}

# check for LAPS module
if (-not (Get-Module -ListAvailable -Name LAPS)) {
    Write-Error "The LAPS module is not installed. Please install it and try again."
    exit
}

# check for administrative privileges
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Error "You do not have administrative privileges. Please run this script as an administrator and try again."
    exit
}

# get the local administrator password for the specified computer
$password = Get-LapsADPassword -Identity $computer -AsPlainText

Write-Host ""
# write output full password variable if verbose switch is used
if ($verbosity -eq "--verbose" -or $verbosity -eq "-v") {
    Write-Output $password
}
else {
    Write-Host "Local administrator password for computer $computer-> " -ForegroundColor Green
    Write-Output $password.Password
}

