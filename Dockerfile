FROM ubuntu:bionic-20181204
LABEL maintainer="sameer@damagehead.com"

ENV SQUID_VERSION=4.4-1 \
    SQUID_CACHE_DIR=/var/spool/squid/cache \
    SQUID_CERT_DIR=/var/spool/squid/ssl_db \
    SQUID_LOG_DIR=/var/log/squid \
    SQUID_USER=proxy

# add diladele apt key
RUN apt-get update && apt-get install -y wget gnupg && wget -qO - http://packages.diladele.com/diladele_pub.asc | apt-key add -

# add repo
RUN echo "deb http://squid44.diladele.com/ubuntu/ bionic main" > /etc/apt/sources.list.d/squid44.diladele.com.list

RUN apt-get update \
 && DEBIAN_FRONTEND=noninteractive apt-get install -y squid=${SQUID_VERSION}* \
 && rm -rf /var/lib/apt/lists/*

COPY entrypoint.sh /sbin/entrypoint.sh
RUN chmod 755 /sbin/entrypoint.sh

COPY squid.conf /etc/squid
RUN cd /etc/squid && \
	mkdir ssl_cert && \
	chown proxy:proxy ssl_cert && \
	chmod 700 ssl_cert && \
	cd ssl_cert && \
	yes $'\\n' | openssl req -new -newkey rsa:2048 -sha256 -days 365 -nodes -x509 -extensions v3_ca -keyout myCA.pem  -out myCA.pem -subj "/C=AU/ST= /L= /O= /OU= /CN= "

EXPOSE 3128/tcp
ENTRYPOINT ["/sbin/entrypoint.sh"]
