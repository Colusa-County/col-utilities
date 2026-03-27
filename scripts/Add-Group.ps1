##
# Add-Group.ps1
# Description: This script adds a user account to a specified security group in Active Directory.
# Parameters:
#    -Username: The username of the account to be added to the group (required)
#    -GroupName: The name of the security group to which the user will be added (required)
# Example usage:
#    .\Add-Group.ps1 -Username "jdoe" -GroupName "IT Department"
##

[CmdletBinding()]
param (
    [Parameter(Mandatory=$true)]
    [string]$Username,

    [Parameter(Mandatory=$true)]
    [string]$GroupName
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

# attempt to add the user to the group
try {
    Add-ADGroupMember -Identity $GroupName -Members $Username -ErrorAction Stop
    Write-Host "The user '$Username' has been successfully added to the group '$GroupName'." -ForegroundColor Green
}
catch {
    Write-Error "An error occurred while trying to add the user to the group: $_"
}