# Build caddy from source
FROM alpine:edge AS build-caddy

LABEL maintainer="Lee Keitel" \
      name="lfkeitel/caddy" \
      version="0.10.10" \
      vcs-type="git" \
      vcs-url="https://github.com/lfkeitel/caddy-docker"

ENV caddy_version=0.10.10

RUN apk update \
    && apk add go libcap bash alpine-sdk \
    && rm -rf /var/cache/apk/*

ADD https://github.com/mholt/caddy/archive/v$caddy_version.tar.gz /caddy.tar.gz

RUN mkdir -p $HOME/go/src/github.com/mholt \
    && cd $HOME/go/src/github.com/mholt \
    && tar -xzf /caddy.tar.gz \
    && mv caddy-$caddy_version caddy \
    && cd caddy/caddy \
    && go get \
    && go build -v -o /caddy -ldflags "-X github.com/mholt/caddy/caddy/caddymain.gitTag=$caddy_version"

# Build image with caddy to serve
FROM alpine:edge

COPY --from=build-caddy /caddy /usr/sbin/caddy

RUN apk update \
    && apk add libcap \
    && addgroup -S caddy \
    && adduser -S -D -h /var/lib/caddy -s /sbin/nologin -G caddy -g caddy caddy \
    && chmod +x /usr/sbin/caddy \
    && install -d -o caddy -g caddy /var/lib/caddy /etc/caddy /var/www \
    && chown caddy:caddy /usr/sbin/caddy \
    && setcap cap_net_bind_service=+ep /usr/sbin/caddy \
    && apk del libcap \
    && rm -rf /var/cache/apk/*

ADD caddy.conf /etc/caddy/caddy.conf

EXPOSE 80 443

CMD ["/usr/sbin/caddy", "-conf", "/etc/caddy/caddy.conf"]
