# acrobat reader re-install

$app = "Acrobat Reader"
$WingetId = "Adobe.Acrobat.Reader.64-bit"

Write-Host "Starting reinstall for Acrobat ..."

function IsAdmin {
    $currentUser = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())

    return $currentUser.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

if (-not (IsAdmin)) {
    Write-Host "Not an Administrator, closing."
    exit 1;
}

$wingetInstalled = $false

try {
    $wingetList = winget list --id $WingetId --exact --accept-source-agreements 2>$null;

    if ($wingetList -match $WingetId) {
        $wingetInstalled = $true;
        Write-Host "$app detected via Winget. Uninstalling ..." -ForegroundColor Yellow
        winget uninstall --id $WingetId --exact --silent --accept-source-agreements --purge
    }

}
catch {
    Write-Error "Error with winget uninstall/check"
}

if (-not $wingetInstalled) {
    Write-Host "Winget detection failed, searching for traditional install ..." -ForegroundColor Yellow

    $uninstallPaths = @(
        "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall",
        "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall"
    )

    $found = $false;

    foreach ($path in $uninstallPaths) {
        if (Test-Path $path) {
            Get-ChildItem $path | ForEach-Object {
                $program = Get-ItemProperty $_.PSPath -ErrorAction SilentlyContinue
                if ($program.DisplayName -like "*Adobe Acrobat Reader*" -or $program.DisplayName -like "*Acrobat Reader*") {
                    $found = $true
                    $uninstallString = $program.UninstallString

                    if ($uninstallString) {
                        Write-Host "Found install:  $($program.DisplayName). Uninstalling ..." -ForegroundColor Green

                        if ($uninstallString -match "msiexec") {
                            $productCode = $uninstallString -replace '.*({[A-Z0-9-]+}).*', '%1'

                            Start-Process msiexec.exe -ArgumentList "/x $productCode /qn /norestart" -Wait -NoNewWindow
                        }
                        else {
                            # exe uninstall
                            $uninstallString = $uninstallString.Trim('"')
                            Start-Process $uninstallString -ArgumentList "/S /quiet" -Wait -NoNewWindow
                        }
                    }
                }
            }
        }
    }

    if (-not $found) {
        Write-Host "No Existing Installation of $app found." -ForegroundColor Green
    }
}

start-sleep -seconds 5

write-host "Installing $app via winget ..." -ForegroundColor Green

winget install --id $WingetId --exact --silent --accept-package-agreements --accept-source-agreements --scope machine


# verifyy

$check = winget list --id $WingetId --exact 2>$null

if ($check -match $WingetId) {
    write-host "success, verify installation manually" -ForegroundColor Green
}
else {
    write-host "something went horribly wrong, bailing! Good luck!" -ForegroundColor Red
}

write-host "done" -ForegroundColor Cyan