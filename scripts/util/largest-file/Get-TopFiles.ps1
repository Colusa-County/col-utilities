

param(
    [string] $ComputerName = $env:COMPUTERNAME
)

Clear-Host

# prompt user for admin rights
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator"))
{
    Write-Warning "This script must be run as an Administrator. Please restart PowerShell as Administrator and try again."
    exit 1
}

$allFiles = @()


$uncRoot = "\\$ComputerName\C$\Users"
Write-Host "Scanning drive $uncRoot for files..."
# exit 1
Get-ChildItem -Path $uncRoot -Recurse -File -ErrorAction SilentlyContinue |
ForEach-Object {
    # write to console the current object being processed
    $currentObject = [pscustomobject]@{
        FullName = $_.FullName
        Length = $_.Length
    }

    Write-Host "Processing file: $($currentObject.FullName) - Size: $($currentObject.Length) bytes"

    $allFiles += $currentObject
}

$topFiles = $allFiles | Sort-Object -Property Length -Descending

$topFiles | ForEach-Object {
    # if any file is over 1GB in size, write to console
    if ($_.Length -gt 1GB)
    {
        $sizeInGB = [math]::Round($_.Length / 1GB, 2)
        Write-Host "Large file found: $($_.FullName) - Size: $sizeInGB GB"
    }
}

# output entire $topFiles list from largest file to smallest along with their sizes in MB with clean formatting
$topFiles | ForEach-Object {
    $sizeInMB = [math]::Round($_.Length / 1MB, 2)
    Write-Host "Size: $sizeInMB MB -- File: $($_.FullName)"
}

#export this list to a csv file and open it in excel
$exportPath = "C:\LargestFiles_$ComputerName.csv"
$topFiles | Select-Object FullName, @{Name="SizeInMB";Expression={[math]::Round($_.Length / 1MB, 2)}} | Export-Csv -Path $exportPath -NoTypeInformation -Encoding UTF8
Write-Host "Exported largest files list to $exportPath"
Start-Process excel.exe $exportPath