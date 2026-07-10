[CmdletBinding()]
param (
    [string]$TargetComputer
)

$sys = Get-WmiObject -Class Win32_ComputerSystem -ComputerName $TargetComputer
$os = Get-WmiObject -Class Win32_OperatingSystem -ComputerName $TargetComputer
$cpu = Get-WmiObject -Class Win32_Processor -ComputerName $TargetComputer
$bios = Get-WmiObject -Class Win32_BIOS -ComputerName $TargetComputer

# Display Formatted Output
Write-Output "=== System Information ==="
Write-Output ("Make          : {0}" -f $sys.Manufacturer)
Write-Output ("Model         : {0}" -f $sys.Model)
Write-Output ("Serial Number : {0}" -f $bios.SerialNumber)
Write-Output ("OS            : {0}" -f $os.Caption)
Write-Output ("Architecture  : {0}" -f $os.OSArchitecture)
Write-Output ("CPU           : {0}" -f $cpu.Name)
Write-Output ("Cores         : {0}" -f $cpu.NumberOfCores)
Write-Output ("Logical Procs : {0}" -f $cpu.NumberOfLogicalProcessors)
Write-Output ("RAM (GB)      : {0:n2}" -f ($sys.TotalPhysicalMemory / 1GB))
Write-Output ("Uptime        : {0}" -f $os.LastBootUpTime)