#!/bin/sh
source lets.conf
docker run --detach --name lets-alpine --env EMAIL=$EMAIL --env DOMAIN=$DOMAIN_STRING  --env STAGING=1 --publish 80:80 --publish 443:443 -v /etc/letsencrypt:/etc/letsencrypt -v /etc/periodic/monthly/:/etc/periodic/monthly/ -v /etc/ssl/dhparams.pem:/etc/ssl/dhparams.pem -e UPSTREAM=$UPSTREAM --log-driver json-file c12e/lets-alpine

