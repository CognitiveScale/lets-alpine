#!/bin/sh
source ./lets.conf
echo "Running docker "
echo "docker run --name lets-alpine --env EMAIL=${EMAIL} --env DOMAIN=${DOMAIN} --env DOMAIN_STRING=\'${DOMAIN_STRING}\' --env STAGING=1 --publish 80:80 --publish 443:443 -v /etc/letsencrypt:/etc/letsencrypt -v /etc/periodic/monthly/:/etc/periodic/monthly/ -v /etc/ssl/dhparams.pem:/etc/ssl/dhparams.pem --log-driver json-file c12e/lets-alpine:release-master"

docker run --name lets-alpine --env EMAIL=${EMAIL} --env DOMAIN=${DOMAIN} --env DOMAIN_STRING=\'${DOMAIN_STRING}\' --env STAGING=1 --publish 80:80 --publish 443:443 -v /etc/letsencrypt:/etc/letsencrypt -v /etc/periodic/monthly/:/etc/periodic/monthly/ -v /etc/ssl/dhparams.pem:/etc/ssl/dhparams.pem --log-driver json-file c12e/lets-alpine:release-master


container_id=`docker ps -a | grep c12e/lets-alpine:release-master | cut -d ' ' -f 1`

echo "Removing container_id $container_id"

docker rm $container_id
