FROM alpine:3.2
MAINTAINER Ash Wilson <smashwilson@gmail.com>

RUN apk add --update  \
  python python-dev py-pip \
  gcc musl-dev linux-headers \
  augeas-dev openssl-dev libffi-dev ca-certificates dialog \
  && rm -rf /var/cache/apk/*

RUN pip install -U letsencrypt

# used for webroot reauth
RUN mkdir -p /etc/letsencrypt/webrootauth

ADD entrypoint.sh /entrypoint.sh

EXPOSE 80 443

ENTRYPOINT ["/entrypoint.sh"]
