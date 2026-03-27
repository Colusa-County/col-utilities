##
# Lock-Account.ps1
# Description: This script will lock the account for the supplied username in Active Directory
# Parameters:
#   -username: The username of the user to lock account for
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

# get the user object from AD
try {
    $user = Get-ADUser -Identity $username -ErrorAction Stop
}
catch {
    Write-Error "Failed to find user '$username' in Active Directory. Please ensure the username is correct and try again."
    exit
}

# attempt to lock the account
try {
    Set-ADUser -Identity $username -LockedOut $true -ErrorAction Stop
    Write-Host "The account for user '$username' has been successfully locked." -ForegroundColor Green
}
catch {
    Write-Error "Failed to lock the account for user '$username'. Please ensure you have the necessary permissions and try again."
    exit
}

