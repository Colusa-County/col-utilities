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

#  store version number in a variable for later use
$version = "1.0.0"

# variables for USMT
$storeLocation = ""
$configFilePath = ""


Clear-Host
Write-Host ""
Write-Host "Welcome to cUtil v$version - your command line utility for running scripts!" -ForegroundColor Green
Write-Host "Type 'help' to see available commands, or 'exit' to quit." -ForegroundColor Green
Write-Host ""
Write-Host "Note: Some commands may require administrative privileges or specific parameters to run successfully." -ForegroundColor Yellow
Write-Host "Always refer to the usage information for each command by typing 'help <command>'." -ForegroundColor Yellow
Write-Host ""
# output an email address for users to submit script requests or suggestions to, and encourage them to do so to help expand the functionality of this tool over time, make the email clickable for convenience
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
# get absolute path to the utility-scripts folder for later use
$utilityScriptsPath = Join-Path -Path (Get-Location) -ChildPath "scripts"

#load all available scripts in the utility-scripts folder into an array for later use
$availableScripts = Get-ChildItem -Path $utilityScriptsPath -Filter "*.ps1" | ForEach-Object { $_.BaseName }

while ($true) {
    # read input, remove ":" from the prompt for cleaner display, and execute the command
    # print working directory
    Write-Host "┌──(" -ForegroundColor Red -NoNewLine
        Write-Host "$(whoami)" -ForegroundColor Cyan -NoNewline
            Write-Host ")→ " -ForegroundColor Red -NoNewLine
                Write-Host "$(Get-Location)" -ForegroundColor Cyan -NoNewLine
                    Write-Host " ~" -ForegroundColor Red
    Write-Host "│" -ForegroundColor Red
    Write-Host "└─(" -ForegroundColor Red -NoNewline
        Write-Host "cutil" -ForegroundColor Cyan -NoNewline
            Write-Host ")→ " -ForegroundColor Red -NoNewLine

    # change cursor color to green for input
    # $host.UI.RawUI.ForegroundColor = "DarkGreen"

    $input = Read-Host


    if ($input -eq "exit") {
        Write-Host "Exiting cUtil. Goodbye!" -ForegroundColor Green
        break
    }

    # if the first word of the input is "help" flow into this if statement to provide usage information for the specified command
    elseif ($input.Split(" ")[0] -eq "help" -or $input.Split(" ")[0] -eq "commands")
    {
        if ($input.Split(" ").Length -eq 2 -and $availableScripts -contains $input.Split(" ")[1]) {
            Write-Host "Usage information for command: $($input.Split(" ")[1])" -ForegroundColor Green
            Write-Host "----------------------------------------" -ForegroundColor Green
            Get-Content -Path "$utilityScriptsPath/$($input.Split(" ")[1]).ps1" | ForEach-Object {
                if ($_ -match "^#") {
                    Write-Host $_ -ForegroundColor Cyan
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
    else {
        try {

            if ($input -eq "version")
            {
                Write-Host "CUtil version 1.0.0" -ForegroundColor Green
            }

            elseif ($input -eq "clear" -or $input -eq "cls")
            {
                Clear-Host
                Write-Host $banner -ForegroundColor Magenta
            }

            elseif ($input -eq "usmt")
            {
                # get credentials to run USMT with, since it needs to be run as admin
                $credential = Get-Credential -Message "Enter credentials to run USMT with"
                Start-Process -FilePath "$utilityScriptsPath/../USMT/usmt.exe" -Credential $credential -Wait
                
                # Invoke-Expression "$utilityScriptsPath/../USMT/usmt.exe"
            }

            # if input is a command in availableScripts, execute the corresponding script with the provided parameters
            elseif ($availableScripts -contains $input.Split(" ")[0]) {
                Invoke-Expression "$utilityScriptsPath/$input"
            }

            elseif ($input -eq "")
            {
                # do nothing
            }

            else
            {
                Invoke-Expression $input
            }

        }
        catch {
            Write-Host "Error executing command: $($_.Exception.Message)" -ForegroundColor Red
        }
        
    }
    Write-Host ""
}