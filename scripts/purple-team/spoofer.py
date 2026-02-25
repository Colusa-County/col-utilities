

import smtplib
from email.mime.text import MIMEText

args = []

msg = MIMEText("This is a test email sent from the spoofer script.")

subject_input = input("Subject: ")
msg['Subject'] = subject_input

from_input = input("From addr: ")
msg['From'] = from_input

to_input = input("To addr: ")
msg['To'] = to_input

port_input = input("Port: ")
email_server_input = input("Email server: ")
smtp = smtplib.SMTP(email_server_input, int(port_input))

input("Press enter to send email...")
send_ = smtp.send_message(msg)
print("Email sent!")
smtp.quit()
exit()