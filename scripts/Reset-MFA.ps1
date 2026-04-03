##
# Reset-MFA.ps1
# Description: This script will reset the MFA for the supplied username using Microsoft.Graph API
# Parameters:
#   -username: The username of the user to reset MFA for
##

[CmdletBinding()]
param (
    [string]$username
)

if (-not (Get-Module -ListAvailable -Name Microsoft.Graph)) {
    Write-Error "The Microsoft.Graph module is not installed. Attempting installation.."
    Write-Host "Installing Microsoft.Graph module..." -ForegroundColor Green
    Install-Module -Name Microsoft.Graph -Force -AllowClobber
    if (-not (Get-Module -ListAvailable -Name Microsoft.Graph)) {
        Write-Error "Failed to install Microsoft.Graph module. Please install it manually and try again."
        exit
    }
    exit
}

if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Error "You do not have administrative privileges. Please run this script as an administrator and try again."
    exit
}

try {
    Connect-MgGraph -Scopes "User.ReadWrite.All"
}
catch {
    Write-Error "Failed to connect to Microsoft Graph. Please ensure you have the necessary permissions and try again."
    exit
}

# TODO: Implement MFA reset functionality using Microsoft Graph API
