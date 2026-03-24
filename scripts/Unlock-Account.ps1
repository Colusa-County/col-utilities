##
# Unlock-Account.ps1
# Description: This script takes a username as input and unlocks the corresponding user account in Active Directory. It also includes error handling to provide feedback if the account cannot be found or if there are issues with permissions.
# Parameters:
#    -Username: The username of the account to unlock (required)
# Example usage:
#    .\Unlock-Account.ps1 -Username "jdoe"
##

[CmdletBinding()]
param (
    [Parameter(Mandatory=$true)]
    [string]$Username
)

# check for admin privileges
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Error "You do not have administrator privileges. Please run this script as an administrator and try again."
    exit
}

# check if the ActiveDirectory module is available
if (-not (Get-Module -ListAvailable -Name ActiveDirectory)) {
    Write-Error "The ActiveDirectory module is not available. Please ensure you have the RSAT tools installed and try again."
    exit
}

# import the ActiveDirectory module
Import-Module ActiveDirectory

# attempt to unlock the user account
try {
    $user = Get-ADUser -Identity $Username -ErrorAction Stop
    if ($user.LockoutTime -ne 0) {
        Unlock-ADAccount -Identity $Username
        Write-Host "The account '$Username' has been successfully unlocked." -ForegroundColor Green
    }
    else {
        Write-Host "The account '$Username' is not locked." -ForegroundColor Yellow
    }
}
catch {
    Write-Error "An error occurred while trying to unlock the account: $_"
}