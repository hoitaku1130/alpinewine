FROM alpine:3.10
LABEL maintainer="Hoitaku"

ARG ARCH=x86_64
ARG CN_MIRROR=false

RUN if [ "$CN_MIRROR" = true ]; then sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' /etc/apk/repositories; fi

ENV WINEDLLOVERRIDES="mscoree,mshtml="
ENV WINEPREFIX="/root/wine" 
ENV SCREEN="0 1280x1024x24"
ENV DISPLAY=":1"
ENV LANG=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8

RUN set -ex && \
    echo $ARCH > /etc/apk/arch && \
    echo "Installing dependencies..." && \
    apk add --no-cache xvfb freetype supervisor && \
    export repo_mirror=$(head -1 /etc/apk/repositories | sed -n 's/\/alpine.*$//p') && \
    apk add --no-cache -X $repo_mirror/alpine/edge/community wine && \
    apk add --no-cache x11vnc &&\
    echo "Initializing wine..." && \
    wineboot && \
    wineserver -w && \
    echo "Clean Up..." && \
    rm -rf /var/cache/apk/*

COPY supervisord.conf /etc/
COPY x11vnc.conf /etc/supervisor/conf.d/

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisord.conf"]
