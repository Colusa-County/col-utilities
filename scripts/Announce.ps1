# take user input via param arguments, a string message, then announce this message via text to speech
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