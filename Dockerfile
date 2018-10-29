FROM alpine:3.8

LABEL maintainer="byte@byteflux.net"

ENV TRICKLE_VERSION=596bb13f2bc323fc8e7783b8dcba627de4969e07 \
    DOCKER_VERSION=18.06.1-ce \
    GOOGLE_DRIVE_SETTINGS=/etc/duply/pydrive.yml

COPY trickle /trickle/

RUN apk add --update curl gawk grep duply py2-pip mariadb-client libevent libtirpc && \
    apk add --virtual .build-deps build-base autoconf automake libtool libevent-dev libtirpc-dev && \
    curl -L -o trickle.zip "https://github.com/mariusae/trickle/archive/$TRICKLE_VERSION.zip" && \
    unzip trickle.zip && \
    cd "trickle-$TRICKLE_VERSION" && \
    patch -p1 < /trickle/Makefile.am.patch && \
    autoreconf -if && \
    CFLAGS=-I/usr/include/tirpc LDFLAGS=-ltirpc ./configure --prefix=/usr && \
    make && \
    make install && \
    mv trickle /usr/bin/ && \
    cd .. && \
    rm -r "trickle-$TRICKLE_VERSION" trickle && \
    apk del .build-deps && \
    pip install PyDrive && \
    curl -o docker.tgz "https://download.docker.com/linux/static/stable/x86_64/docker-$DOCKER_VERSION.tgz" && \
    tar xzf docker.tgz --strip-components=1 -C /usr/bin && \
    rm docker.tgz && \
    mkdir -p /etc/duply /var/cache/duply /root/.cache && \
    mv /etc/crontabs/root /etc/duply/crontab.txt && \
    ln -s /etc/duply/crontab.txt /etc/crontabs/root && \
    ln -s /var/cache/duply /root/.cache/duplicity && \
    rm /var/cache/apk/*

COPY pydrive.yml /etc/duply/

CMD ["crond", "-f"]