##
# Remove-Group.ps1
# Description: This script removes a user account from a specified security group in Active Directory.
# Parameters:
#    -Username: The username of the account to be removed from the group (required)
#    -GroupName: The name of the security group from which the user will be removed (required)
# Example usage:
#    .\Remove-Group.ps1 -Username "jdoe" -GroupName "IT Department"
##

[CmdletBinding()]
param (
    [Parameter(Mandatory=$true)]
    [string]$Username,

    [Parameter(Mandatory=$true)]
    [string]$GroupName
)

if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Error "You do not have administrator privileges. Please run this script as an administrator and try again."
    exit
}

if (-not (Get-Module -ListAvailable -Name ActiveDirectory)) {
    Write-Error "The ActiveDirectory module is not available. Please ensure you have the RSAT tools installed and try again."
    exit
}

Import-Module ActiveDirectory

# check if the user exists in AD
try {
    $user = Get-ADUser -Identity $Username -ErrorAction Stop
}
catch {
    Write-Error "The user '$Username' does not exist in Active Directory. Please check the username and try again."
    exit
}

# check if the group exists in AD
try {
    $group = Get-ADGroup -Identity $GroupName -ErrorAction Stop
}
catch {
    Write-Error "The group '$GroupName' does not exist in Active Directory. Please check the group name and try again."
    exit
}

try {
    Remove-ADGroupMember -Identity $GroupName -Members $Username -Confirm:$false -ErrorAction Stop
    Write-Host "The user '$Username' has been successfully removed from the group '$GroupName'." -ForegroundColor Green
}
catch {
    Write-Error "An error occurred while trying to remove the user from the group: $_"
}