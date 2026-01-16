
clear
cls

echo "PWNING UNLOCKED PC ..."
sleep 1.5
echo ""
echo "CREATING OUTLOOK APPLICATION OBJECT ..."
sleep 1.5
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

$recipient = $mail.Recipients.Add("itdept@countyofcolusaca.gov")
$recipient.Type = 1

$mail.Subject = "I got PwNt! I left my PC unlocked and unattended!"
$mail.Body = "Sorry about that! I'll do better so I don't get PWNED again.`n`n`nThis message was composed by the email-pwn script `nTiming of pwn: $(Get-Date)"

sleep 1.5

echo $mail
echo ""
echo "PWN EMAIL OBJECT CREATED!"

$mail.Display($false)
# $mail.send()

echo "PWN MAIL SENT!"
echo $userEmail "you got OWNED"
echo "EXITING ..."
sleep 1
echo ""
echo ""
echo ""

[System.Runtime.InteropServices.Marshal]::ReleaseComObject($mail) | Out-Null
[System.Runtime.InteropServices.Marshal]::ReleaseComObject($outlook) | Out-Null
[System.Runtime.InteropServices.Marshal]::ReleaseComObject($namespace) | Out-Null
