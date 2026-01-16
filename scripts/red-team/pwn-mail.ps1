
clear
cls

$sleeping = $false
echo "PWNING UNLOCKED PC ..."

if ($sleeping)
{ 
  sleep 1.5
}

echo ""
echo "CREATING OUTLOOK APPLICATION OBJECT ..."

if ($sleeping)
{
  sleep 1.5
}

$outlook = New-Object -ComObject Outlook.Application
$namespace = $outlook.GetNamespace("MAPI")

echo $outlook

echo ""
echo "OUTLOOK APPLICATION OBJECT CREATED ..."
sleep 1
echo ""
echo "COMPOSING PWN EMAIL OBJECT ..."

$mail = $outlook.CreateItem(0)

$userEmail = $namespace.CurrentUser.AddressEntry.GetExchangeUser().PrimarySmtpAddress

$recipient = $mail.Recipients.Add("hgraves@countyofcolusaca.gov")
$mail.Recipients.Add($userEmail)
$recipient.Type = 1


$mail.Subject = "[EMAIL-PWN] I left my PC unlocked and unattended!"
$mail.Body = "Hi there!`n`nSorry about that! I'll do better so I don't get PWNED again.
        `n`nThis message was composed by the email-pwn script 
        User: $env:USERNAME
        Machine: $env:COMPUTERNAME
        Time: $(Get-Date)"

sleep 1.5

echo $mail
echo ""
echo "PWN EMAIL OBJECT CREATED!"
sleep 1

$mail.Display($false)
$mail.send()

echo "PWN MAIL SENT!"
echo ""
sleep 1
echo "$userEmail, you got OWNED"
echo ""
sleep 1.5
echo "EXITING ..."
sleep 1
echo ""
echo ""
echo ""

[System.Runtime.InteropServices.Marshal]::ReleaseComObject($mail) | Out-Null
[System.Runtime.InteropServices.Marshal]::ReleaseComObject($outlook) | Out-Null
[System.Runtime.InteropServices.Marshal]::ReleaseComObject($namespace) | Out-Null
