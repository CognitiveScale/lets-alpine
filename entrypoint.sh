#!/bin/sh

set -euo pipefail

# Validate environment variables

MISSING=""

[ -z "${DOMAIN}" ] && MISSING="${MISSING} DOMAIN"
[ -z "${EMAIL}" ] && MISSING="${MISSING} EMAIL"

if [ "${MISSING}" != "" ]; then
  echo "Missing required environment variables:" >&2
  echo " ${MISSING}" >&2
  echo " ${USAGE}" >&2
  exit 1
fi

echo "DOMAIN_STRING=${DOMAIN_STRING}"

USAGE="docker run --env DOMAIN=<registered-dns-or-public-ip> \
       [--env DOMAIN_STRING=<DOMAIN_STRING>] c12e/lets-alpine[:tag] \
       -v /etc/letsencrypt:/etc/letsencrypt"

# Default other parameters

SERVER=""
[ -n "${STAGING:-}" ] && SERVER="--server https://acme-staging.api.letsencrypt.org/directory"

# Generate strong DH parameters, if they don't already exist.
#if [ ! -f /etc/ssl/dhparams.pem ]; then
#  if [ -f /cache/dhparams.pem ]; then
#    cp /cache/dhparams.pem /etc/ssl/dhparams.pem
#  else
#    openssl dhparam -out /etc/ssl/dhparams.pem 2048
#    # Cache to a volume for next time?
#    if [ -d /cache ]; then
#      cp /etc/ssl/dhparams.pem /cache/dhparams.pem
#    fi
#  fi
#fi


# Initial certificate request, but skip if cached
if [ ! -f /etc/letsencrypt/live/${DOMAIN}/fullchain.pem ]; then
  letsencrypt certonly \
   --domain ${DOMAIN} \
   ${DOMAIN_STRING} \
   --authenticator standalone \
    ${SERVER} \
    --email "${EMAIL}" --agree-tos
fi

# Template a cronjob to reissue the certificate with the webroot authenticator
cat <<EOF >/etc/periodic/monthly/reissue
#!/bin/sh

set -euo pipefail

# Certificate reissue
letsencrypt certonly --renew-by-default \
  --domain ${DOMAIN} \
  ${DOMAIN_STRING} \
  --authenticator webroot \
  --webroot-path /etc/letsencrypt/webrootauth/ ${SERVER} \
  --email "${EMAIL}" --agree-tos

EOF
chmod +x /etc/periodic/monthly/reissue

# move this outside of container
# /usr/sbin/crond -f -d 8 &

echo Ready
