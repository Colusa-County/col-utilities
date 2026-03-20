##
# Get-GroupCommon.ps1
# Description: This script will get the common group membership in AD for the supplied users
# Parameters:
#   -users: An array of usernames to get common group membership for
##

[CmdletBinding()]
param (
    [string[]]$users
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

# get the common group membership for the users
$commonGroups = $null

foreach ($user in $users) {
    $userGroups = Get-ADPrincipalGroupMembership -Identity $user | Select-Object -ExpandProperty Name
    
    if ($null -eq $commonGroups) {
        $commonGroups = $userGroups
    } else {
        $commonGroups = $commonGroups | Where-Object { $_ -in $userGroups }
    }
}

Write-Host "Common groups for users $($users -join ', ')-> " -ForegroundColor Green
Write-Output $commonGroups