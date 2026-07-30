#Requires -RunAsAdministrator
<#
.SYNOPSIS
    Downloads the latest Microsoft Teams machine-wide installer (teamsbootstrapper.exe)
    from Microsoft's official CDN and installs it system-wide.

.DESCRIPTION
    This script requires elevation. It downloads teamsbootstrapper.exe to the current
    user's Desktop, then runs it with the -p flag for a provisioned/machine-wide install.

.NOTES
    File Name : Install-Teams.ps1
    Requires  : Windows PowerShell 5.1+ or PowerShell 7+, Administrator privileges
#>

$ErrorActionPreference = 'Stop'

# ---------------------------------------------------------------------------
# Configuration
# ---------------------------------------------------------------------------
$DownloadUrl = 'https://statics.teams.cdn.office.net/production-teamsprovision/lkg/teamsbootstrapper.exe'
$InstallerName = 'teamsbootstrapper.exe'
$DesktopPath = [Environment]::GetFolderPath('Desktop')
$InstallerPath = Join-Path -Path $DesktopPath -ChildPath $InstallerName

Write-Host '========================================================' -ForegroundColor Cyan
Write-Host '  Microsoft Teams Machine-Wide Installer' -ForegroundColor Cyan
Write-Host '========================================================' -ForegroundColor Cyan
Write-Host ''

# ---------------------------------------------------------------------------
# Verify elevation (belt-and-suspenders with #Requires)
# ---------------------------------------------------------------------------
Write-Host '[1/4] Verifying administrator privileges...' -ForegroundColor Yellow
$currentPrincipal = New-Object Security.Principal.WindowsPrincipal(
    [Security.Principal.WindowsIdentity]::GetCurrent()
)
if (-not $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Error 'This script must be run as Administrator. Right-click PowerShell and choose "Run as administrator", then re-run the script.'
    exit 1
}
Write-Host '      Running with administrator privileges.' -ForegroundColor Green
Write-Host ''

# ---------------------------------------------------------------------------
# Resolve Desktop path and prepare download destination
# ---------------------------------------------------------------------------
Write-Host '[2/4] Preparing download destination...' -ForegroundColor Yellow
Write-Host "      Desktop path : $DesktopPath"
Write-Host "      Installer    : $InstallerPath"

if (-not (Test-Path -LiteralPath $DesktopPath)) {
    Write-Error "Desktop folder not found at: $DesktopPath"
    exit 1
}

if (Test-Path -LiteralPath $InstallerPath) {
    Write-Host '      Existing installer found on Desktop — removing it first...' -ForegroundColor DarkYellow
    Remove-Item -LiteralPath $InstallerPath -Force
    Write-Host '      Removed previous copy.' -ForegroundColor Green
}
Write-Host ''

# ---------------------------------------------------------------------------
# Download teamsbootstrapper.exe from Microsoft CDN
# ---------------------------------------------------------------------------
Write-Host '[3/4] Downloading Teams bootstrapper from Microsoft CDN...' -ForegroundColor Yellow
Write-Host "      URL : $DownloadUrl"
Write-Host '      This may take a moment depending on your connection...'

try {
    # Prefer Invoke-WebRequest; follows the fwlink redirect to the real CDN asset
    $ProgressPreference = 'SilentlyContinue'  # cleaner console during large downloads
    curl.exe -O $DownloadUrl $InstallerPath
    $ProgressPreference = 'Continue'
}
catch {
    Write-Error "Download failed: $($_.Exception.Message)"
    exit 1
}

if (-not (Test-Path -LiteralPath $InstallerPath)) {
    Write-Error "Download appeared to succeed but file was not found at: $InstallerPath"
    exit 1
}

$fileInfo = Get-Item -LiteralPath $InstallerPath
$sizeMB = [math]::Round($fileInfo.Length / 1MB, 2)
Write-Host "      Download complete. Size: $sizeMB MB" -ForegroundColor Green
Write-Host "      Saved to: $InstallerPath" -ForegroundColor Green
Write-Host ''

# ---------------------------------------------------------------------------
# Execute installer with -p (provision / machine-wide)
# ---------------------------------------------------------------------------
Write-Host '[4/4] Launching Teams bootstrapper (machine-wide provision)...' -ForegroundColor Yellow
Write-Host "      Command: `"$InstallerPath`" -p"
Write-Host '      Waiting for the installer to finish...'
Write-Host ''

try {
    $process = Start-Process -FilePath $InstallerPath `
        -ArgumentList '-p' `
        -WorkingDirectory $DesktopPath `
        -Wait `
        -PassThru `
        -NoNewWindow

    $exitCode = $process.ExitCode
    Write-Host ''
    if ($exitCode -eq 0) {
        Write-Host "      Installer finished successfully (exit code: $exitCode)." -ForegroundColor Green
    }
    else {
        Write-Warning "Installer exited with a non-zero code: $exitCode. Review the output above for details."
    }
}
catch {
    Write-Error "Failed to start or wait on the installer: $($_.Exception.Message)"
    exit 1
}

Write-Host ''
Write-Host '========================================================' -ForegroundColor Cyan
Write-Host '  Done.' -ForegroundColor Cyan
Write-Host "  Installer remains on your Desktop: $InstallerPath" -ForegroundColor Cyan
Write-Host '========================================================' -ForegroundColor Cyan

Remove-Item "$DownloadUrl/teamsbootstrapper.exe"
