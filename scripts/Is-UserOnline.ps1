##
# Script Name: Is-UserOnline.ps1
# Description: This script checks if a specified user is currently online by querying their last logon time from Active Directory. If the last logon time is within the last 15 minutes, the script considers the user to be online.
# Parameters:
#    -Username: The username of the user to check (e.g., "jdoe")
# Example usage:
#    .\Is-UserOnline.ps1 -Username "jdoe"
##


param (
    [Parameter(Mandatory=$true)]
    [string]$Username
)

Import-Module ActiveDirectory -ErrorAction SilentlyContinue
if (-not (Get-Module -Name ActiveDirectory)) {
    Write-Error "ActiveDirectory module is not available. Please ensure RSAT tools are installed."
    exit 1
}

function Is-UserOnline {
    param($Username)
    try {
        $user = Get-ADUser -Identity $Username -Properties LastLogonDate
        if ($null -eq $user) {
            Write-Error "User $Username not found in Active Directory."
            return $false
        }

        $lastLogon = $user.LastLogonDate
        if ($null -eq $lastLogon) {
            Write-Host "User $Username has never logged on."
            return $false
        }

        $timeSpan = (Get-Date) - $lastLogon
        if ($timeSpan.TotalMinutes -le 15) {
            Write-Host "User $Username is currently online (Last logon: $lastLogon)."
            return $true
        } else {
            Write-Host "User $Username is currently offline (Last logon: $lastLogon)."
            return $false
        }
    } catch {
        Write-Error "Error checking user status: $($_.Exception.Message)"
        return $false
    }
}



$isOnline = Is-UserOnline -Username $Username
if ($isOnline) {
    Write-Host "User $Username is online."
    exit 0
} else {
    Write-Host "User $Username is offline."
    exit 1
}