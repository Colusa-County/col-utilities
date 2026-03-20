##
# Get-GroupDiff.ps1
# Description: This script will compare the group membership of two users in AD and return the differences, if there are 3 or more users passed in as arguments, the script will find all the groups that every user has in common that the last user doesn't have.
# Parameters:
#   -an array of usernames to compare group membership for
##

[CmdletBinding()]
param (
    [string[]]$usernames
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


# create a hashtable to store the group membership for each user
$groupMembership = @{}

# loop through each username and get their group membership
foreach ($username in $usernames) {
    $groups = Get-ADPrincipalGroupMembership -Identity $username | Select-Object -ExpandProperty Name
    $groupMembership[$username] = $groups
}

# if there are only 2 users, compare their group membership and return the differences
if ($usernames.Count -eq 2) {
    $user1Groups = $groupMembership[$usernames[0]]
    $user2Groups = $groupMembership[$usernames[1]]

    $user1OnlyGroups = $user1Groups | Where-Object { $_ -notin $user2Groups }
    $user2OnlyGroups = $user2Groups | Where-Object { $_ -notin $user1Groups }

    Write-Output "Groups only in $($usernames[0]):"
    Write-Output $user1OnlyGroups
    Write-Output "Groups only in $($usernames[1]):"
    Write-Output $user2OnlyGroups
}

# if there are 3 or more users, find all the groups that every user has in common that the last user doesn't have
elseif ($usernames.Count -ge 3) {
    $commonGroups = $groupMembership[$usernames[0]]

    for ($i = 1; $i -lt $usernames.Count - 1; $i++) {
        $commonGroups = $commonGroups | Where-Object { $_ -in $groupMembership[$usernames[$i]] }
    }

    $lastUserGroups = $groupMembership[$usernames[-1]]
    $uniqueGroups = $commonGroups | Where-Object { $_ -notin $lastUserGroups }

    Write-Output "Groups that every user has in common that the last user doesn't have:"
    Write-Output $uniqueGroups
}