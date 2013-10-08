# mail-stack-delivery + spamassassin
# the mail-stack-delivery package will install Dovecot and configure Postfix to use it for both SASL authentication and as a Mail Delivery Agent (MDA). 
# The package also configures Dovecot for IMAP, IMAPS, POP3, and POP3S.

from		ubuntu

env		DEBIAN_FRONTEND noninteractive

env		DOMAIN example.com
env		HOSTNAME mail.$DOMAIN
env		SSLSUBJ	/C=AU/ST=VIC/L=Melbourne/O=Dis/CN=$DOMAIN

run		echo "$HOSTNAME" > /etc/hostname
run		echo "$DOMAIN" > /etc/mailname

## disable upstart
run		dpkg-divert --local --rename --add /sbin/initctl && ln -s /bin/true /sbin/initctl

run		apt-get install -y --no-install-recommends netbase
run		sed -i -e "/^127.0.0.1/s/$/ $HOSTNAME/" /etc/hosts

run		apt-get install -y --no-install-recommends mail-stack-delivery spamassassin rsyslog

## disable POP3
run		sed -i -e "/^protocols/s/ pop3//" /etc/dovecot/conf.d/01-mail-stack-delivery.conf
## disable sieve
run		sed -i -e "/^protocols/s/ sieve//" /etc/dovecot/conf.d/01-mail-stack-delivery.conf
## store mail under /var/mail
run		sed -i -e "\#^mail_location#s#~/Maildir#/var/mail/%u#" /etc/dovecot/conf.d/01-mail-stack-delivery.conf

## comment out home_mailbox line
run		sed -i -e "/^home_mailbox/s/^/#/" /etc/postfix/main.cf
## append   mail_spool_directory
run		echo "mail_spool_directory = /var/mail" >> /etc/postfix/main.cf

## generate new certificate
run		rm /etc/ssl/certs/ssl-mail.pem
run		rm /etc/ssl/private/ssl-mail.key
run		openssl req -new -newkey rsa:4096 -x509 -days 3650 -nodes -subj "$SSLSUBJ" -out /etc/ssl/certs/ssl-mail.pem -keyout /etc/ssl/private/ssl-mail.key

## enable port 587 (submission)
run		sed -i -e "s/^#submission/submission/" /etc/postfix/master.cf
## enable port 465 (smtps)
run		sed -i -e "s/^#smtps/smtps/" /etc/postfix/master.cf

## enable spamassassin daemon
run		sed -i -e "/^ENABLED/s/0/1/" /etc/default/spamassassin
## enable cron update of spamassassin rules
# run		sed -i -e "/^CRON/s/0/1/" /etc/default/spamassassin

# android push config?

volume 		/var/mail/
#volume	spamassassin rules?

expose 		25 993 143 587 465
##ports: 25 smtp   993 imaps   143 imap   587 submission   465 smtps

run		echo -e "#!/bin/bash\n/usr/sbin/rsyslogd && service postfix start && service spamassassin start && /usr/sbin/dovecot -c /etc/dovecot/dovecot.conf && tail -f /var/log/mail.log" > /bin/mailserver
run		chmod +x /bin/mailserver
cmd		/bin/mailserver

## development lines;
run	apt-get install nano
# sudo docker build -t "mailserver" .
# sudo docker run -i -t mailserver /bin/bash
# sudo docker run -p 25:25 -p 993:993 -p 143:143 -p 587:587 -p 465:465 mailserver
