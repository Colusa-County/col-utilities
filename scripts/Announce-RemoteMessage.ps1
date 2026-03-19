##
# Announce-RemoteMessage.ps1
# Description: This script takes a computer name and a string message as input, then uses text-to-speech to announce the message aloud on the specified remote computer. It also includes an optional parameter to specify how many times the message should be repeated.
# Parameters:
#    -ComputerName: The name of the remote computer to announce the message on (required
#    -Message: The string message to be announced (required)
#    -RepeatCount: The number of times to repeat the announcement (optional, default is
# Example usage:
#    .\Announce-RemoteMessage.ps1 -ComputerName "RemotePC" -Message "Hello, this is an announcement!" -RepeatCount 3
#
# Note: This script requires that PowerShell remoting is enabled on the target computer and that the user has the necessary permissions to execute commands remotely.
##

param (
    [Parameter(Mandatory=$true)]
    [string]$ComputerName,

    [Parameter(Mandatory=$true)]
    [string]$Message,

    [Parameter(Mandatory=$false)]
    [int]$RepeatCount = 2
)
# use Invoke-Command to run the Announce.ps1 script on the remote computer
$scriptBlock = {
    param($Message, $RepeatCount)
    Add-Type -AssemblyName System.Speech
    $synthesizer = New-Object System.Speech.Synthesis.SpeechSynthesizer

    for ($i = 0; $i -lt $RepeatCount; $i++) {
        Start-Sleep -Seconds 1
        [console]::beep(300, 1000)
        $synthesizer.Speak($Message)
    }
}

Invoke-Command -ComputerName $ComputerName -ScriptBlock $scriptBlock -ArgumentList $Message, $RepeatCount
