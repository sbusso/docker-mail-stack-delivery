docker-mail-stack-delivery
==========================

Dockerfile to build mail-stack-delivery + spamassassin

The mail-stack-delivery package will install Dovecot and configure Postfix to use it for both SASL authentication and as a Mail Delivery Agent (MDA).
The package also configures Dovecot for IMAP, IMAPS, POP3, and POP3S.

    curl -s https://raw.github.com/Thermionix/docker-mail-stack-delivery/master/Dockerfile | sudo docker build -t="mailserver" -
    sudo docker run -p 25:25 -p 993:993 -p 143:143 -p 587:587 -p 465:465 mailserver
    
