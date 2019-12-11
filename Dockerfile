# Build caddy from source
FROM alpine:edge AS build-caddy

LABEL maintainer="Lee Keitel" \
    name="lfkeitel/caddy" \
    version="1.0.4" \
    vcs-type="git" \
    vcs-url="https://github.com/lfkeitel/caddy-docker"

ENV caddy_version=1.0.4

RUN apk update \
    && apk add go libcap bash alpine-sdk \
    && rm -rf /var/cache/apk/*

ADD https://github.com/mholt/caddy/archive/v$caddy_version.tar.gz /caddy.tar.gz

# Get source and unpack
RUN mkdir -p $HOME/go/src/github.com/mholt \
    && cd $HOME/go/src/github.com/mholt \
    && tar -xzf /caddy.tar.gz \
    && mv caddy-$caddy_version caddy

WORKDIR /root/go/src/github.com/mholt/caddy/caddy

# Apply patches and customizations
COPY caddyrun_telemetry.go caddymain/caddyrun_telemetry.go

RUN sed -i -e 's/Version: "unknown"/Version: "(Onesimus Systems Build)"/g' ./caddymain/run.go \
    && sed -i -e 's/endpoint+/Endpoint+/g' ../telemetry/telemetry.go \
    && sed -i -e '/endpoint =/d' ../telemetry/telemetry.go \
    && echo 'var Endpoint = "https://telemetry.caddyserver.com/v1/update/"' >> ../telemetry/telemetry.go

# Build
RUN go get \
    && go build -v -o /caddy -ldflags "-X github.com/mholt/caddy/caddy/caddymain.gitTag=$caddy_version"

# Build image with caddy to serve
FROM alpine:edge

ENV CADDYPATH=/caddy
COPY --from=build-caddy /caddy /usr/sbin/caddy

RUN apk update \
    && apk add libcap \
    && addgroup -S caddy \
    && adduser -S -D -h /var/lib/caddy -s /sbin/nologin -G caddy -g caddy caddy \
    && chmod +x /usr/sbin/caddy \
    && install -d -o caddy -g caddy /var/lib/caddy /etc/caddy /var/www /caddy \
    && chown caddy:caddy /usr/sbin/caddy \
    && setcap cap_net_bind_service=+ep /usr/sbin/caddy \
    && apk del libcap \
    && rm -rf /var/cache/apk/*

USER caddy
ADD caddy.conf /etc/caddy/caddy.conf

EXPOSE 80 443

ENTRYPOINT ["/usr/sbin/caddy", "-conf", "/etc/caddy/caddy.conf"]
