##
# Reset-Password.ps1
# Description: This script will reset the password for the supplied username in Active Directory
# Parameters:
#   -username: The username of the user to reset password for
##

[CmdletBinding()]
param (
    [string]$username
)

if (-not (Get-Module -ListAvailable -Name ActiveDirectory)) {
    Write-Error "The Active Directory module is not installed. Please install it and try again."
    exit
}

if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Error "You do not have administrative privileges. Please run this script as an administrator and try again."
    exit
}

try {
    $user = Get-ADUser -Identity $username -ErrorAction Stop
}
catch {
    Write-Error "Failed to find user '$username' in Active Directory. Please ensure the username is correct and try again."
    exit
}

$newPassword = Read-Host -Prompt "Enter the new password for user '$username'" -AsSecureString

try {
    Set-ADAccountPassword -Identity $username -NewPassword $newPassword -Reset -ErrorAction Stop
    Write-Host "The password for user '$username' has been successfully reset." -ForegroundColor Green
}
catch {
    Write-Error "Failed to reset the password for user '$username'. Please ensure you have the necessary permissions and try again."
    exit
}

