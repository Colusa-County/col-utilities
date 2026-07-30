##
# Get-Connections.ps1
# Description: This script retrieves information about active network connections on a 
#              specified remote Windows 11 computer. 
#              It requires administrative privileges on the target computer 
#              and the ability to access its network interfaces remotely via WMI objects.
# Parameters:
#    -TargetComputer: The name of the remote computer to query
# Example usage:
#    .\Get-Connections.ps1 -TargetComputer "RemotePC"
##

[CmdletBinding()]
param (
    [Parameter(Mandatory = $true)]
    [string]$TargetComputer,

    [Parameter(Mandatory = $false)]
    [string]$manualMode = "",

    [Parameter(Mandatory = $false)]
    [int]$sleepTimer = 5

)

# force manual mode for now
$manualMode = "--manual"

# Check for administrative privileges
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Warning "This script must be run as an Administrator. Please restart PowerShell as Administrator and try again."
    exit 1
}
$warning = "











            _______    _______    _         _________   _          _______ 
|\     /|  (  ___  )  (  ____ )  ( (    /|  \__   __/  ( (    /|  (  ____ \
| )   ( |  | (   ) |  | (    )|  |  \  ( |     ) (     |  \  ( |  | (    \/
| | _ | |  | (___) |  | (____)|  |   \ | |     | |     |   \ | |  | |      
| |( )| |  |  ___  |  |     __)  | (\ \) |     | |     | (\ \) |  | | ____ 
| || || |  | (   ) |  | (\ (     | | \   |     | |     | | \   |  | | \_  )
| () () |  | )   ( |  | ) \ \__  | )  \  |  ___) (___  | )  \  |  | (___) |
(_______)  |/     \|  |/   \__/  |/    )_)  \_______/  |/    )_)  (_______)
"

# Clear the screen and display banner
Clear-Host

Write-Host $warning -ForegroundColor Red

# play a small beep to get their attention
[console]::beep(500, 700)
[console]::beep(500, 700)


Clear-Host

# output "WARNING" in ascii art in red
Write-Host $warning -ForegroundColor Red

# Display big warning in red about proper usage of this script, and force user to press enter to confirm they understand the risks
Write-Host "WARNING: This script is intended for ethical use only. Unauthorized access to computer systems is illegal and unethical. 
Ensure you have explicit permission to access the target computer and its network traffic before proceeding.
" -ForegroundColor Red

# display their username and current computer name for accountability
$currentUser = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name
$currentComputer = $env:COMPUTERNAME
Write-Host "Current User: $currentUser" -ForegroundColor Yellow
Write-Host "Current Computer: $currentComputer" -ForegroundColor Yellow

Write-Host "
By proceeding, you confirm that you understand the risks and have the necessary permissions to use this script responsibly." -ForegroundColor Red

# force the user to type "confirm" to proceed
$confirmation = Read-Host "
Type 'confirm' to proceed or Ctrl+C to exit"
if ($confirmation -ne "confirm") {
    Write-Host "Confirmation not received. Exiting script." -ForegroundColor Yellow
    exit 1
}

Clear-Host

# Check if the target computer is online
if (-not (Test-Connection -ComputerName $TargetComputer -Count 1 -Quiet)) {
    Write-Warning "Computer $TargetComputer is not reachable. Please check the computer name and network connection, then try again."
    exit 1
}

$networkInterfaces = $null

# Attempt to access the network interfaces of the target computer
try {
    Write-Host "Attempting to access network interfaces on $TargetComputer..." -ForegroundColor Green
    $networkInterfaces = Get-WmiObject -Class Win32_NetworkAdapter -ComputerName $TargetComputer -ErrorAction Stop

    if ($networkInterfaces) {
        Write-Host "Successfully accessed network interfaces on $TargetComputer." -ForegroundColor Green
        Write-Host "Available Network Adapters:" -ForegroundColor Cyan
        foreach ($adapter in $networkInterfaces) {
            Write-Host "Name: $($adapter.Name), MAC Address: $($adapter.MACAddress), Status: $($adapter.NetConnectionStatus)" -ForegroundColor Yellow
        }

    }
    else {
        Write-Warning "No network interfaces found on $TargetComputer."
    }
}
catch {
    Write-Output "Failed to access network interfaces on $TargetComputer : $($_.Exception.Message)"
}


$stateMap = @{
    1 = 'Closed'; 2 = 'Listen'; 3 = 'SynSent'; 4 = 'SynReceived'; 5 = 'Established'; 
    6 = 'FinWait1'; 7 = 'FinWait2'; 8 = 'CloseWait'; 9 = 'Closing'; 10 = 'LastAck'; 
    11 = 'TimeWait'; 12 = 'DeleteTCB'
}

$dnsCache = @{}
$previousConnections = @{}


try {
    Write-Host "Realtime inbound/outbound connections on $TargetComputer : (Ctrl+C to stop)" -ForegroundColor Green
    if ($manualMode -eq "-m" -or $manualMode -eq "--manual") {
        Write-Host "
        
        Manual mode enabled. Press Enter to retreive connections..." -ForegroundColor Cyan
        Read-Host
    }
    else {
        Write-Host "
        
        Auto-refresh every $sleepTimer seconds. Press Ctrl+C to stop." -ForegroundColor Yellow
        Start-Sleep 5
    }

    while ($true) {
        Write-Host "Realtime inbound/outbound connections on $TargetComputer : (Ctrl+C to stop)" -ForegroundColor Green
        Write-Host "Refresh: $(Get-Date) | Target: $TargetComputer" -ForegroundColor Yellow
        Write-Host "======================================================================================================================" -ForegroundColor Cyan
        $processMap = @{}
        Get-WmiObject -Class Win32_Process -ComputerName $TargetComputer -ErrorAction Stop |
        ForEach-Object { 
            $processMap[[int]$_.ProcessId] = [PSCustomObject]@{
                Name = $_.Name; CmdLine = $_.CommandLine
            }
        }

        $tcpConnections = Get-WmiObject -Namespace root\StandardCimv2 -Class MSFT_NetTCPConnection -ComputerName $TargetComputer -ErrorAction Stop

        

        # Get-WmiObject -Class Win32_Process -ComputerName $TargetComputer | ForEach-Object { $proccessMap[[int]$_.ProcessId] = [PSCustomObject]@{Name=$_.Name; CmdLine=$_.CommandLine}}
        
        $enriched = foreach ($c in $tcpConnections) {
            $stateString = $stateMap[[int]$c.State]
            $process = $processMap[[int]$c.OwningProcess]
            $remoteIP = $c.RemoteAddress

            # DNS resolution (cached runs on host (my) machine)
            $remoteHost = $remoteIP
            if ($remoteIP -and $remoteIP -notmatch '^127\.|^::1|^0\.0\.0\.0' -and -not $dnsCache.ContainsKey($remoteIP)) {
                try {
                    $dnsCache[$remoteIP] = (Resolve-DnsName $remoteIP -Type PTR -ErrorAction Stop).NameHost

                }
                catch { $dnsCache[$remoteIP] = $remoteIP }
            }

            if ($dnsCache.ContainsKey($remoteIP)) { $remoteHost = $dnsCache[$remoteIP] }

            # direction heuristic
            $direction = if ($stateString -eq 'Listen') {
                'Listening (Inbound)'
            }
            elseif ($stateString -eq 'Established') {
                if ($c.LocalPort -ge 1024 -and $c.RemotePort -le 1023) { 'Outbound (client -> server)' }
                elseif ($c.LocalPort -le 1023 -and $c.RemotePort -ge 1024) { 'Inbound (server -> client)' }
                else { 'Established (unknown direction)' }
            }
            else { $stateString }

            $key = "$($c.LocalAddress):$($c.LocalPort) -> $($c.RemoteAddress):$($c.RemotePort) PID:$($c.OwningProcess)"


            [PSCustomObject]@{
                Protocol    = 'TCP'
                Local       = "$($c.LocalAddress):$($c.LocalPort)"
                RemoteIP    = $remoteIP
                RemoteHost  = $remoteHost
                RemotePort  = $c.RemotePort
                State       = $stateString
                Direction   = $direction
                ProcessName = $process.Name
                PID         = $c.OwningProcess
                CommandLine = $process.CmdLine
                IsNew       = -not $previousConnections.ContainsKey($key)
            }
        }

        # udp listeners (in case of exfil malware)
        $udpConnections = Get-WmiObject -Namespace root\StandardCimv2 -Class MSFT_NetUDPEndpoint -ComputerName $TargetComputer -ErrorAction SilentlyContinue

        $udpEnriched = $udpConnections | ForEach-Object {
            $process = $processMap[[int]$_.OwningProcess]
            [PSCustomObject]@{
                Protocol    = 'UDP'
                Local       = "$($_.LocalAddress):$($_.LocalPort)"
                RemoteIP    = '*'
                RemoteHost  = '*'
                RemotePort  = '*'
                State       = 'N/A'
                Direction   = 'UDP Listener'
                ProcessName = $process.Name
                PID         = $_.OwningProcess
                CommandLine = $process.CmdLine
                IsNew       = $false
            }
        }

        $all = $enriched + $udpEnriched | Sort-Object Direction, ProcessName, Local, RemoteIP, RemotePort

        # display highlights on new connections
        $all | Format-Table -AutoSize -Wrap @{
            Label      = "Connection"; 
            Expression = { 
                if ($_.IsNew) { 
                    ">>> $($_.Local) -> $($_.RemoteHost):$($_.RemotePort): " 
                } 
                else { 
                    "$($_.Local) -> $($_.RemoteHost):$($_.RemotePort): " 
                } 
            }
        }, Direction, ProcessName, PID, State, CommandLine

        # update cache
        $previousConnections.Clear()
        $enriched | ForEach-Object {
            $previousConnections[$_.Local + '->' + $_.RemoteIP] = $true
        }

        if ($manualMode -eq "-m" -or $manualMode -eq "--manual") {
            Write-Host "Manual mode enabled. Press Enter to refresh connections..." -ForegroundColor Cyan
            Write-Host "type 'exit' to stop monitoring." -ForegroundColor Yellow
            $user_input = Read-Host
            if ($user_input -eq "exit") {
                Write-Host "Exiting monitoring loop." -ForegroundColor Green
                break
            }
        }
        else {
            Start-Sleep -Seconds $sleepTimer
        }
    }
}
catch {
    Write-Warning "Error: $($_.Exception.Message)"

}
finally {
    Write-Host "Monitoring stopped. Exiting." -ForegroundColor Green
}

