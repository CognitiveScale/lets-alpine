# Let's Nginx

*[dockerhub build](https://hub.docker.com/r/c12e/lets-alpine/)*

Put browser-valid TLS termination in front of any Dockerized HTTP service with one command.

Based on https://hub.docker.com/r/smashwilson/lets-nginx/
But removing nginx for use cases where nginx proxying already exists and we only want the certs.
This could be a chron job run on intervals to renew the certs.
The container deposits certs into /etc/letsencrypt/<dns-hostname-or-ip>.
These certs can be shared by all docker containers running on the host.

```bash
docker run --detach \
  --name lets-nginx \
  --link backend:backend \
  --env EMAIL=me@email.com \
  --env DOMAIN=mydomain.horse \
  --env ALT_DOMAIN=proxydomain.horse \
  --publish 80:80 \
  --publish 443:443 \
  c12e/lets-alpine
```

Issues certificates from [letsencrypt](https://letsencrypt.org/), installs them in /etc/letsencrypt, and optionally schedules a cron job to reissue them monthly.

:zap: To run unattended, this container accepts the letsencrypt terms of service on your behalf. Make sure that the [subscriber agreement](https://letsencrypt.org/repository/) is acceptable to you before using this container. :zap:

## Prerequisites

Before you begin, you'll need:

 1. A [place to run Docker containers](https://getcarina.com/) with a public IP.
 2. A domain name with an *A record* pointing to your cluster.

## Usage

Launch your backend container and note its name, then launch `smashwilson/lets-nginx` with the following parameters:

 * `-e EMAIL=` your email address, used to register with letsencrypt.
 * `-e DOMAIN=` the domain name.
 * `-p 80:80` and `-p 443:443` so that the letsencrypt client and nginx can bind to those ports on your public interface.
 * `-e STAGING=1` uses the Let's Encrypt *staging server* instead of the production one.
            I highly recommend using this option to double check your infrastructure before you launch a real service.
            Let's Encrypt rate-limits the production server to issuing
            [five certificates per domain per seven days](https://community.letsencrypt.org/t/public-beta-rate-limits/4772/3),
            which (as I discovered the hard way) you can quickly exhaust by debugging unrelated problems!

## Caching the Certificates and/or DH Parameters

Optional: If you prefer to mount docker volumes rather than deposit them to the host /etc/letsencrypt, do this once

```bash
docker volume create --name letsencrypt
docker volume create --name letsencrypt-backups
docker volume create --name dhparam-cache
```

and then start the container with volume attachments:

```bash
docker run --detach \
  --name lets-nginx \
  --env EMAIL=me@email.com \
  --env DOMAIN=mydomain.horse \
  --env ALT_DOMAIN=myproxydomain.horse \
  --publish 80:80 \
  --publish 443:443 \
  -v letsencrypt:/etc/letsencrypt \
  -v letsencrypt-backups:/var/lib/letsencrypt \
  -v dhparam-cache:/cache \
  c12e/lets-alpine
```

