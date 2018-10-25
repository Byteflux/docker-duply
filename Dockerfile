FROM alpine:3.8

LABEL maintainer="byte@byteflux.net"

ENV DOCKER_VERSION=18.06.1-ce \
    GOOGLE_DRIVE_SETTINGS=/etc/duply/pydrive.yml

RUN apk add --update curl duply py2-pip mariadb-client && \
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