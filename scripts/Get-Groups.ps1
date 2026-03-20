##
# Get-Groups.ps1
# Description: This script will get the active group membership in AD for the supplied user
# Parameters:
#   -username: The username of the user to get group membership for
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

# get the group membership for the user
$groups = Get-ADPrincipalGroupMembership -Identity $username | Select-Object -ExpandProperty Name

Write-Host "Groups for user $username-> " -ForegroundColor Green
Write-Output $groups

