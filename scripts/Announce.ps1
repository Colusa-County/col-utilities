##
# Announce.ps1
# Description: This script takes a string message as input and uses text-to-speech to announce the message aloud. It also includes an optional parameter to specify how many times the message should be repeated.
# Parameters:
#    -Message: The string message to be announced (required)
#    -RepeatCount: The number of times to repeat the announcement (optional, default is 2)
# Example usage:
#    .\Announce.ps1 -Message "Hello, this is an announcement!" -RepeatCount 3
##

[CmdletBinding()]
param (
    [Parameter(Mandatory=$true)]
    [string]$Message,

    [Parameter(Mandatory=$false)]
    [int]$RepeatCount = 2
)
Add-Type -AssemblyName System.Speech
$synthesizer = New-Object System.Speech.Synthesis.SpeechSynthesizer


# make a loop to repeat this message 5 times
for ($i = 0; $i -lt $RepeatCount; $i++) {
    Start-Sleep -Seconds 1
    [console]::beep(300, 1000)
    $synthesizer.Speak($Message)
}