##
# @name         Spoofer Script
# @version:     1.0
# @date:        2024-06-01
# @file:        spoofer.py
# @author:      Colusa County IT Purple Team // Henry Graves
# @description: This script is designed to send spoofed emails for testing purposes. 
#               It can read email details from a configuration file or prompt the user for input.
#
# Usage: python spoofer.py [config_file]
# The configuration file should have the following format:
# Body: <email body>
# Subject: <email subject>
# From: <sender email address>
# To: <recipient email address>
# Email Server: <SMTP server address>
# Port: <SMTP server port>
#
# If no configuration file is provided, the script will prompt the user to enter the required details.
##

import sys
import smtplib
from email.mime.text import MIMEText

args = sys.argv

if len(args) == 2:
    # parse file
    body_input = ""
    subject_input = ""
    from_input = ""
    to_input = ""
    port_input = ""
    email_server_input = ""
    with open(args[1], 'r') as f:
        for line in f:
            if line.startswith("Body:"):
                body_input = line.split("Body:")[1].strip()
            elif line.startswith("Subject:"):
                subject_input = line.split("Subject:")[1].strip()
            elif line.startswith("From:"):
                from_input = line.split("From:")[1].strip()
            elif line.startswith("To:"):
                to_input = line.split("To:")[1].strip()
            elif line.startswith("Port:"):
                port_input = line.split("Port:")[1].strip()
            elif line.startswith("Email Server:"):
                email_server_input = line.split("Email Server:")[1].strip()
    
    print(f"Email body: {body_input}")
    print(f"Email subject: {subject_input}")
    print(f"Email from: {from_input}")
    print(f"Email to: {to_input}")
    print(f"Email server: {email_server_input}")
    print(f"Port: {port_input}")

    msg = MIMEText(body_input)

else:
    # prompt for input
    body_input = input("Email body: ")
    msg = MIMEText(body_input)

    subject_input = input("Subject: ")
    from_input = input("From addr: ")
    to_input = input("To addr: ")
    port_input = input("Port: ")
    email_server_input = input("Email server: ")


msg['Subject'] = subject_input
msg['From'] = from_input
msg['To'] = to_input

smtp = smtplib.SMTP(email_server_input, int(port_input))

input("Press enter to send email...")
send_ = smtp.send_message(msg)
print("Email sent!")
smtp.quit()
exit()