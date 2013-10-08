Docker-mail-stack-delivery
==========================

Dockerfile to build mail-stack-delivery

    curl -s https://raw.github.com/Thermionix/Docker-mail-stack-delivery/master/Dockerfile | sudo docker build -t="mailserver" -
    sudo docker run -p 25:25 -p 993:993 -p 143:143 -p 587:587 -p 465:465 mailserver
