#! /usr/bin/env python

import smtplib
from email.MIMEMultipart import MIMEMultipart
from email.MIMEBase import MIMEBase
from email.MIMEText import MIMEText
from email import Encoders
import os
import sys

from smtplib import SMTP, quotedata, CRLF, SMTPDataError
from sys import stderr

class ExtendedSMTP(SMTP): 	
    def data(self,msg):
        """
	This is a modified copy of smtplib.SMTP.data()
		
	Sending data in chunks and calling self.callback
	to keep track of progress,
	"""
        self.putcmd("data")
        (code,repl)=self.getreply()

        if code != 354:
            raise SMTPDataError(code,repl)
        else:
            q = quotedata(msg)
            if q[-2:] != CRLF:
                q = q + CRLF
            q = q + "." + CRLF
            
            # begin modified send code
            chunk_size = 2048
            bytes_sent = 0
            
            while bytes_sent != len(q):
                chunk = q[bytes_sent:bytes_sent+chunk_size]
                self.send(chunk)
                bytes_sent += len(chunk)
                if hasattr(self, "callback"):
                    self.callback(bytes_sent, len(q))
            # end modified send code
            
            (code,msg)=self.getreply()
            return (code,msg)


def callback(progress, total):
    sys.stdout.write ( "%s\n" % (str(int(round(100.0*progress/total)))))
    sys.stdout.flush()


gmail_user = os.environ['SHELLTOOLS_GMAIL_UNAME']
gmail_pwd = os.environ['SHELLTOOLS_GMAIL_PASSWORD']
to = os.environ['SHELLTOOLS_KINDLE_AUTHORISED_EMAIL']

def mail(attach):
	msg = MIMEMultipart()
	
	msg['From'] = gmail_user
	msg['To'] = to
	msg['Subject'] = ""

	msg.attach(MIMEText(""))
	if len(attach) > 25:
		print "# Maximum 25 files only"
		return 
		
	
	for att in attach:
		part = MIMEBase('application', 'octet-stream')
		part.set_payload(open(att, 'rb').read())
		Encoders.encode_base64(part)
		part.add_header('Content-Disposition', 'attachment; filename="%s"' % os.path.basename(att))
		
		msg.attach(part)

	mailServer = ExtendedSMTP("smtp.gmail.com", 587)
	mailServer.callback = callback
	mailServer.ehlo()
	mailServer.starttls()
	mailServer.ehlo()
	mailServer.login(gmail_user, gmail_pwd)
	
	tsize = len(msg.as_string())
	if tsize > 25*1024*1024: # 25MB - gmail limit, kindle limit is higher
		print "# Maximum of 25MB allowed. Current size: " + str(tsize)
		return

	mailServer.sendmail(gmail_user, to, msg.as_string())

	# Should be mailServer.quit(), but that crashes...
	mailServer.close()


if __name__ == "__main__":
	print sys.argv[1:]
	mail(sys.argv[1:])
