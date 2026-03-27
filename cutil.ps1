##
# cutil.ps1
# Description: This command line tool will act as a cli for all other scripts in this repo. Running ./cutil drops you into an interactive shell to run scripts.
# Example usage:
#      ./cutil
# (then inside of cutil):
#      cutil-> Get-File -TargetComputer "RemotePC" -RemoteFilePath "\\RemotePC\C$\Path\To\File.txt" -LocalSavePath "C:\Local\Path\File.txt"
#     cutil-> Get-Procs -TargetComputer "RemotePC"
#     cutil-> tap-connections -TargetComputer "RemotePC"
#     cutil-> usmt  # launches USMT
#     cutil-> exit
##

# [Console]::TreatControlCAsInput = $true

# ignore ctrl+c in parent shell
Add-Type -TypeDefinition @'
using System;
using System.Runtime.InteropServices;

public class ConsoleCtrlHandler
{
    [DllImport("Kernel32")]
    public static extern bool SetConsoleCtrlHandler(HandlerRoutine handler, bool add);
    private delegate bool HandlerRoutine(int ctrlType);
    
    private static bool Handler(int ctrlType)
    {
        // 0 = CTRL_C_EVENT
        if (ctrlType == 0)
        {
            // ignore ctrl+c
            return true;
        }
        return false;
    }
    
    public static void Install()
    {
        SetConsoleCtrlHandler(new HandlerRoutine(Handler), true);
    }

}
'@

[ConsoleCtrlHandler]::Install()

$version = "1.0.0"

# compute the hash of the cutil.ps1 file and store it in a variable to check for changes later
function Get-FileHashString {
    param (
        [string]$filePath
    )
    if (Test-Path -Path $filePath) {
        $hash = Get-FileHash -Path $filePath -Algorithm SHA256
        return $hash.Hash
    }
    else {
        Write-Host "File not found: $filePath" -ForegroundColor Red
        return $null
    }
}

$versionHash = Get-FileHashString -filePath $MyInvocation.MyCommand.Path

$storeLocation = ""
$configFilePath = ""

Clear-Host
Write-Host ""
Write-Host $versionHash -ForegroundColor Yellow
Write-Host ""
Write-Host "Welcome to cUtil v$version - your command line utility for running scripts!" -ForegroundColor Green
Write-Host "Type 'help' to see available commands, or 'exit' to quit." -ForegroundColor Green
Write-Host ""
Write-Host "Note: Some commands may require administrative privileges or specific parameters to run successfully." -ForegroundColor Yellow
Write-Host "Always refer to the usage information for each command by typing 'help <command>'." -ForegroundColor Yellow
Write-Host ""
Write-Host "Have a script suggestion/request? send an email to: " -ForegroundColor white -NoNewLine
Write-Host "hgraves@countyofcolusaca.gov" -ForegroundColor Cyan
write-Host ""
write-Host ""
$banner = "
 ▄▄▄▄ ██  ██ ▄▄▄▄▄▄ ▄▄ ▄▄    
██▀▀▀ ██  ██   ██   ██ ██    
▀████ ▀████▀   ██   ██ ██▄▄▄  Colusa County Script Utilities v$version                         
"
Write-Host $banner -ForegroundColor Magenta
$utilityScriptsPath = Join-Path -Path (Get-Location) -ChildPath "scripts"

function Get-AvailableScripts{
    try {
        $availableScripts = Get-ChildItem -Path $utilityScriptsPath -Filter "*.ps1" | ForEach-Object { $_.BaseName }
    }
    catch {
        Write-Host "Error loading available scripts: $($_.Exception.Message)" -ForegroundColor Red
        Write-Host "Use the set-script-path command to specify the correct path to the utility scripts." -ForegroundColor Yellow
        $availableScripts = @()
    }
    return $availableScripts
}

$availableScripts = Get-AvailableScripts

try {
    while ($true) {
        # print working directory
        Write-Host "┌──(" -ForegroundColor Red -NoNewLine
            Write-Host "$(whoami)" -ForegroundColor Cyan -NoNewline
                Write-Host ")→ " -ForegroundColor Red -NoNewLine
                    Write-Host "$(Get-Location)" -ForegroundColor Cyan -NoNewLine
                        Write-Host " ~" -ForegroundColor Red
        Write-Host "│" -ForegroundColor Red
        Write-Host "└─(" -ForegroundColor Red -NoNewline
            Write-Host "cUtil" -ForegroundColor Cyan -NoNewline
                Write-Host ")→ " -ForegroundColor Red -NoNewLine

        $UserInput = Read-Host

        if ($UserInput -eq "exit") {
            Write-Host "Exiting cUtil. Goodbye!" -ForegroundColor Green
            break
        }

        if ($UserInput -eq "set-script-path") {
            # check for the argument passed in with the set-script-path command, if no argument is passed in prompt the user to enter a path
            if ($UserInput.Split(" ").Length -eq 1) {
                $utilityScriptsPath = Read-Host "Enter the new path to the utility scripts"
            }
            else {
                $utilityScriptsPath = $UserInput.Split(" ")[1]
            }
            Write-Host "Utility scripts path set to: $utilityScriptsPath" -ForegroundColor Green
            write-host ""
            $availableScripts = Get-AvailableScripts
            continue
        }
        if ($UserInput -eq "show-script-path") {
            Write-Host "Current utility scripts path: $utilityScriptsPath" -ForegroundColor Green
            write-host ""
            continue
        }

        ##
        ## HELP COMMAND BLOCK
        ##
        # if the first word of the input is "help" flow into this if statement to provide usage information for the specified command
        if ($UserInput.Split(" ")[0] -eq "help" -or $UserInput.Split(" ")[0] -eq "commands")
        {
            if ($UserInput.Split(" ").Length -eq 2 -and $availableScripts -contains $UserInput.Split(" ")[1]) {
                Write-Host "Usage information for command: $($UserInput.Split(" ")[1])" -ForegroundColor Green
                Write-Host "----------------------------------------" -ForegroundColor Green
                Get-Content -Path "$utilityScriptsPath/$($UserInput.Split(" ")[1]).ps1" | ForEach-Object {
                    if ($_ -match "^#") {
                        Write-Host $_ -ForegroundColor Cyan
                    }
                }
            }
            # else if user types "help" with partial command name, show commands that match the partial name
            elseif ($UserInput.Split(" ").Length -eq 2) {
                $partialName = $UserInput.Split(" ")[1]
                $matchingCommands = $availableScripts | Where-Object { $_ -like "*$partialName*" }
                $matchedCommand = ""
                if ($matchingCommands.Count -gt 0) {
                    Write-Host "Commands matching '$partialName':" -ForegroundColor Green
                    $matchingCommands | ForEach-Object { Write-Host "  $_" -ForegroundColor Cyan; $matchedCommand = $_ }
                }
                # if matching commands.count is == 1 then also show usage information for the matching command
                if ($matchingCommands.Count -eq 1) {
                    Write-Host "Usage information for command: $($matchedCommand)" -ForegroundColor Green
                    Write-Host "----------------------------------------" -ForegroundColor Green
                    Get-Content -Path "$utilityScriptsPath/$($matchedCommand).ps1" | ForEach-Object {
                        if ($_ -match "^#") {
                            Write-Host $_ -ForegroundColor Cyan
                        }
                    }
                }
            }
            
            else {
                # display available scripts by listing the files in the utility-scripts folder
                Write-Host "Available scripts:" -ForegroundColor Green
                Get-ChildItem -Path $utilityScriptsPath -Filter "*.ps1" | ForEach-Object {
                    $commandName = $_.BaseName
                    Write-Host "  $commandName" -ForegroundColor Cyan
                }
                Write-Host "  help" -ForegroundColor Cyan
                Write-Host "  exit" -ForegroundColor Cyan
            }
        }
        ##
        ## END HELP COMMAND BLOCK
        ##

        else {
            try {

                if ($UserInput -eq "version")
                {
                    Write-Host "CUtil version 1.0.0" -ForegroundColor Green
                }
                elseif ($UserInput -eq "")
                {
                    # do nothing
                    write-host ""
                    continue
                }

                if ($UserInput -eq "launch-gui")
                {
                    # launch the GUI script
                    Invoke-Expression "$utilityScriptsPath/../cutil-gui.ps1"
                    continue
                }

                # if input is a command in availableScripts, execute the corresponding script with the provided parameters
                if ($availableScripts -contains $UserInput.Split(" ")[0]) {
                    Invoke-Expression "$utilityScriptsPath/$UserInput"
                }
                else
                {
                    Invoke-Expression $UserInput
                    
                }

            }
            catch {
                Write-Host "Error executing command: $($_.Exception.Message)" -ForegroundColor Red
            }
            
        }
        Write-Host ""
    }

}
catch {
    Write-Host "An unexpected error occurred: $($_.Exception.Message)" -ForegroundColor Red
}
finally {
    [Console]::TreatControlCAsInput = $false
    Write-Host "Thank you for using cUtil!" -ForegroundColor Green
}