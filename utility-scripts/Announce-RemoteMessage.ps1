# target a computer (taken in by parameters) on the network by hostname and announce a message taken in by param via text to speech
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
