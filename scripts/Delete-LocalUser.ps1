##
## USAGE: Delete-LocalUser.ps1 user1, user2, user3
##
## Array usage: 
##  users = [user1, user2, user3]
##  Delete-LocalUser.ps1 $users
##

param(
    [Parameter(Mandatory = $true, Position = 0)]
    [string[]]$UserAccounts
)

# Requires administrator privileges
if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Error "This script must be run as Administrator"
    exit 1
}

foreach ($user in $UserAccounts) {
    Write-Host "`n[Processing] Removing profile for: $user" -ForegroundColor Cyan
    
    # Get SID for the user
    try {
        $sidObj = New-Object System.Security.Principal.NTAccount($user)
        $sidString = $sidObj.Translate([System.Security.Principal.SecurityIdentifier]).Value
        Write-Host "[INFO] User SID: $sidString" -ForegroundColor Gray
        
        # Remove user profile from CIM/WMI
        $profiles = Get-CimInstance Win32_UserProfile | Where-Object { $_.SID -eq $sidString }
        
        foreach ($profile in $profiles) {
            Write-Host "[ACTION] Deleting profile path: $($profile.LocalPath)" -ForegroundColor Yellow
            Remove-CimInstance -InputObject $profile
            
            # Force profile folder deletion if it still exists
            if (Test-Path $profile.LocalPath) {
                Remove-Item -Path $profile.LocalPath -Recurse -Force -ErrorAction SilentlyContinue
                Write-Host "[INFO] Profile folder deleted" -ForegroundColor Green
            }
        }
        
        # Clean up registry entries
        $regPaths = @(
            "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList\$sidString",
            "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList\$sidString\DefaultUser"
        )
        
        foreach ($path in $regPaths) {
            if (Test-Path $path) {
                Remove-Item -Path $path -Recurse -Force
                Write-Host "[INFO] Registry key cleaned: $path" -ForegroundColor Gray
            }
        }
        
        # Clean temporary files associated with user
        $tempPaths = @(
            "C:\Users\Default\AppData\Local\Temp\$($user)_*",
            "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\$user*"
        )
        
        foreach ($tempPath in $tempPaths) {
            Get-ChildItem -Path $tempPath -Recurse -ErrorAction SilentlyContinue | Remove-Item -Force -Recurse -ErrorAction SilentlyContinue
        }
        
        Write-Host "[COMPLETE] Removed all traces for: $user" -ForegroundColor Green
        
    }
    catch {
        Write-Warning "[ERROR] Failed to process $user : $($_.Exception.Message)"
    }
}

Write-Host "`n[SUMMARY] Processed $($UserAccounts.Count) user account(s)" -ForegroundColor Cyan